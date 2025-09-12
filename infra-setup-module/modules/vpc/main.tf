terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

data "aws_region" "current" {}

locals {
  # Separate public and private subnets based on var.subnets
  local_public_subnets = {
    for k, cfg in var.subnets : k => cfg if lookup(cfg, "public", false)
  }

  local_private_subnets = {
    for k, cfg in var.subnets : k => cfg if !lookup(cfg, "public", false)
  }

  public_subnet_count  = length(local.local_public_subnets)
  private_subnet_count = length(local.local_private_subnets)
}

# Guardrail: fail early if private subnets exist but no public subnets
resource "null_resource" "validate_private_public" {
  count = var.enforce_private_requires_public && local.private_subnet_count > 0 && local.public_subnet_count == 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
echo 'ERROR: Guardrail: private subnets exist but no public subnet to host a NAT gateway.'
echo 'Set enforce_private_requires_public=false to bypass.'
exit 1
EOT
  }
}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-vpc" })
}

# Internet Gateway (only if public subnets exist)
resource "aws_internet_gateway" "this" {
  count  = local.public_subnet_count > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-igw" })
}

# Subnets
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = merge(local.common_tags,
    { Name = "${each.key}-${var.client_name}-${local.common_tags.Env}-${var.application}-subnet" })
}

# Public Route Table
resource "aws_route_table" "public" {
  count  = local.public_subnet_count > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-public-rt" })
}

# Default route to IGW
resource "aws_route" "public_default_to_igw" {
  count = local.public_subnet_count > 0 && length(aws_internet_gateway.this) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

# Associate public subnets to public RT
resource "aws_route_table_association" "public" {
  for_each = {
    for k, s in aws_subnet.this : k => s if lookup(var.subnets[k], "public", false)
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

# NAT EIP (only if private + public subnets exist)
resource "aws_eip" "nat_eip" {
  count  = local.private_subnet_count > 0 && local.public_subnet_count > 0 ? 1 : 0
  domain = "vpc"

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-nat-eip" })
}

# NAT Gateway
locals {
  public_subnet_ids = [for k, s in aws_subnet.this : s.id if lookup(var.subnets[k], "public", false)]
}

resource "aws_nat_gateway" "nat" {
  count = length(aws_eip.nat_eip) > 0 ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = length(local.public_subnet_ids) > 0 ? local.public_subnet_ids[0] : null

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-nat-gw" })

  depends_on = [aws_internet_gateway.this]
}

# Private Route Table
resource "aws_route_table" "private" {
  count  = local.private_subnet_count > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-private-rt" })
}

# Private default route to NAT
resource "aws_route" "private_default_to_nat" {
  count = local.private_subnet_count > 0 && length(aws_nat_gateway.nat) > 0 ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

# Associate private subnets to private RT
resource "aws_route_table_association" "private" {
  for_each = {
    for k, s in aws_subnet.this : k => s if !lookup(var.subnets[k], "public", false)
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  count             = local.private_subnet_count > 0 ? 1 : 0
  vpc_id            = aws_vpc.this.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  route_table_ids   = [aws_route_table.private[0].id]

  tags = merge(local.common_tags,
    { Name = "${var.client_name}-${local.common_tags.Env}-${var.application}-s3-endpoint" })
}
