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

  local_public_subnets = {
    for subnet_key, subnet_cfg in var.subnets : subnet_key => subnet_cfg if subnet_cfg.public
  }

  local_private_subnets = {
    for subnet_key, subnet_cfg in var.subnets : subnet_key => subnet_cfg if !subnet_cfg.public
  }
  public_subnet_count  = length([for s in var.subnets : s if lookup(s, "public", false)])
  private_subnet_count = length([for s in var.subnets : s if !lookup(s, "public", false)])
}

# Guardrail: fail early if private subnets exist but no public subnets
resource "null_resource" "validate_private_public" {
  count = var.enforce_private_requires_public && local.private_subnet_count > 0 && local.public_subnet_count == 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: Guardrail: private subnets exist but no public subnet to host a NAT gateway. Set enforce_private_requires_public=false to bypass.' && exit 1"
  }
}

# # VPC
# resource "aws_vpc" "this" {
#   cidr_block           = var.cidr_block
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "${var.name}-vpc"
#   }
# }

# # Internet Gateway (only if public subnets exist)
# resource "aws_internet_gateway" "this" {
#   count  = local.public_subnet_count > 0 ? 1 : 0
#   vpc_id = aws_vpc.this.id

#   tags = { Name = "${var.name}-igw" }
# }

# # Subnets
# resource "aws_subnet" "this" {
#   for_each = var.subnets

#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = each.value.cidr_block
#   availability_zone       = each.value.az
#   map_public_ip_on_launch = lookup(each.value, "public", false)

#   tags = {
#     Name = "${var.name}-${each.key}"
#   }
# }

# # Public route table (one per VPC if public subnets exist)
# resource "aws_route_table" "public" {
#   count  = local.public_subnet_count > 0 ? 1 : 0
#   vpc_id = aws_vpc.this.id

#   tags = { Name = "${var.name}-public-rt" }
# }

# # Default public route to IGW
# resource "aws_route" "public_default" {
#   count = length(aws_route_table.public) > 0 && length(aws_internet_gateway.this) > 0 ? 1 : 0

#   route_table_id         = aws_route_table.public[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.this[0].id
# }

# # Associate public subnets to public RT
# resource "aws_route_table_association" "public_assoc" {
#   for_each = { for k, s in var.subnets : k => s if lookup(s, "public", false) }

#   subnet_id      = aws_subnet.this[each.key].id
#   route_table_id = aws_route_table.public[0].id
# }

# # Private route table (one per VPC if private subnets exist)
# resource "aws_route_table" "private" {
#   count  = local.private_subnet_count > 0 ? 1 : 0
#   vpc_id = aws_vpc.this.id

#   tags = { Name = "${var.name}-private-rt" }
# }

# # NAT: EIP + NAT Gateway if both private and public subnets exist
# resource "aws_eip" "nat_eip" {
#   count = local.private_subnet_count > 0 && local.public_subnet_count > 0 ? 1 : 0
#   vpc   = true

#   tags = { Name = "${var.name}-nat-eip" }
# }

# resource "aws_nat_gateway" "nat" {
#   count = length(aws_eip.nat_eip) > 0 ? 1 : 0

#   allocation_id = aws_eip.nat_eip[0].id

#   subnet_id = element([
#     for k, s in aws_subnet.this : s.id if lookup(var.subnets[k], "public", false)
#   ], 0)

#   depends_on = [aws_internet_gateway.this]

#   tags = { Name = "${var.name}-natgw" }
# }

# # Private default route to NAT
# resource "aws_route" "private_default" {
#   count = length(aws_route_table.private) > 0 && length(aws_nat_gateway.nat) > 0 ? 1 : 0

#   route_table_id         = aws_route_table.private[0].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat[0].id
# }

# # Associate private subnets to private RT
# resource "aws_route_table_association" "private_assoc" {
#   for_each = { for k, s in var.subnets : k => s if !lookup(s, "public", false) }

#   subnet_id      = aws_subnet.this[each.key].id
#   route_table_id = aws_route_table.private[0].id
# }

# # S3 Gateway Endpoint for private route table
# resource "aws_vpc_endpoint" "s3" {
#   count             = local.private_subnet_count > 0 ? 1 : 0
#   vpc_id            = aws_vpc.this.id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = local.private_subnet_count > 0 ? [aws_route_table.private[0].id] : []

#   tags = { Name = "${var.name}-s3-endpoint" }
# }
