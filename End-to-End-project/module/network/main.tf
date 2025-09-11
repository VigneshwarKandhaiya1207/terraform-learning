data "aws_region" "current" {}

locals {
  all_subnets = merge([
    for vpc_key, vpc_cfg in var.vpc_configs : {
      for subnet_key, subnet_cfg in vpc_cfg.subnet_config :
      "${vpc_key}-${subnet_key}" => merge(subnet_cfg, {
        vpc_key    = vpc_key
        subnet_key = subnet_key
      })
    }
  ]...)

  public_subnets = {
    for key, cfg in local.all_subnets : key => cfg
    if lookup(cfg, "public", false)
  }

  private_subnets = {
    for key, cfg in local.all_subnets : key => cfg
    if !lookup(cfg, "public", false)
  }

  # VPCs that have at least one public subnet
  vpcs_with_public = {
    for vpc_key, vpc_cfg in var.vpc_configs :
    vpc_key => vpc_cfg
    if length([
      for _, s in vpc_cfg.subnet_config : s if lookup(s, "public", false)
    ]) > 0
  }

  # VPCs that have at least one private subnet
  vpcs_with_private = {
    for vpc_key, vpc_cfg in var.vpc_configs :
    vpc_key => vpc_cfg
    if length([
      for _, s in vpc_cfg.subnet_config : s if !lookup(s, "public", false)
    ]) > 0
  }

  # VPCs that need NAT (must have at least one private AND at least one public)
  vpcs_needing_nat = {
    for vpc_key, vpc_cfg in var.vpc_configs :
    vpc_key => vpc_cfg
    if (
      length([
        for _, s in vpc_cfg.subnet_config : s if !lookup(s, "public", false)
      ]) > 0
      &&
      length([
        for _, s in vpc_cfg.subnet_config : s if lookup(s, "public", false)
      ]) > 0
    )
  }

  # For each vpc with public subnets, capture ordered list of public subnet keys (e.g. "vpc1-subnet1")
  public_subnet_keys_by_vpc = {
    for vpc_key, _ in local.vpcs_with_public :
    vpc_key => sort([
      for k, s in local.public_subnets : k if s.vpc_key == vpc_key
    ])
  }

  # Compute a first_public_subnet_key per vpc (used to place the NAT GW).
  first_public_subnet_key = {
    for vpc_key, keys in local.public_subnet_keys_by_vpc :
    vpc_key => keys[0]
    if length(keys) > 0
  }

  # For route table association convenience: private route table ids will be referenced by vpc key
  # (aws_route_table.private will create those entries keyed by vpc_key)
}

# -------------------------
# Create VPCs
# -------------------------
resource "aws_vpc" "this" {
  for_each   = var.vpc_configs
  cidr_block = each.value.vpc_config.cidr_block

  tags = {
    Name = each.key
  }
}

# -------------------------
# Create Subnets
# -------------------------
resource "aws_subnet" "this" {
  for_each          = local.all_subnets
  vpc_id            = aws_vpc.this[each.value.vpc_key].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  map_public_ip_on_launch = lookup(each.value, "public", false)

  tags = {
    Name = "${each.value.vpc_key}-${each.value.subnet_key}"
  }
}

# -------------------------
# Internet Gateways (only for VPCs that have public subnets)
# -------------------------
resource "aws_internet_gateway" "this" {
  for_each = local.vpcs_with_public
  vpc_id   = aws_vpc.this[each.key].id

  tags = {
    Name = "${each.key}-igw"
  }
}

# -------------------------
# Elastic IP for NAT (only for VPCs that need NAT)
# -------------------------
resource "aws_eip" "nat" {
  for_each = local.vpcs_needing_nat

  vpc = true

  tags = {
    Name = "${each.key}-nat-eip"
  }
}

# -------------------------
# NAT Gateways (only for VPCs that need NAT)
# Place NAT in first public subnet for that VPC (first_public_subnet_key)
# -------------------------
resource "aws_nat_gateway" "this" {
  for_each = local.vpcs_needing_nat

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[local.first_public_subnet_key[each.key]].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${each.key}-natgw"
  }
}

# -------------------------
# Route Tables
# One public RT per VPC that has public subnets
# One private RT per VPC that has private subnets
# -------------------------
resource "aws_route_table" "public" {
  for_each = local.vpcs_with_public

  vpc_id = aws_vpc.this[each.key].id

  # default route to IGW
  dynamic "route" {
    for_each = [1]
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this[each.key].id
    }
  }

  tags = {
    Name = "${each.key}-public-rt"
  }
}

resource "aws_route_table" "private" {
  for_each = local.vpcs_with_private

  vpc_id = aws_vpc.this[each.key].id

  tags = {
    Name = "${each.key}-private-rt"
  }
}

# -------------------------
# Private default route to NAT (only for vpcs that need NAT)
# Create a default route (0.0.0.0/0) in private RT pointing to NAT
# -------------------------
resource "aws_route" "private_default_to_nat" {
  for_each = local.vpcs_needing_nat

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

# -------------------------
# Route Table Associations
# Associate each public subnet to its VPC's public route table
# Associate each private subnet to its VPC's private route table
# -------------------------
resource "aws_route_table_association" "public_assoc" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_key].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private[each.value.vpc_key].id
}

# -------------------------
# S3 Gateway VPC Endpoint (per VPC that has private subnets)
# Attach to the private route table so private subnets resolve S3 via endpoint
# -------------------------
resource "aws_vpc_endpoint" "s3" {
  for_each = local.vpcs_with_private

  vpc_id       = aws_vpc.this[each.key].id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach endpoint to the (single) private route table for the VPC
  # If you want to attach to multiple route tables per VPC, supply the list here.
  route_table_ids = [
    aws_route_table.private[each.key].id
  ]

  tags = {
    Name = "${each.key}-s3-gw-endpoint"
  }

  depends_on = [
    aws_route_table.private
  ]
}
