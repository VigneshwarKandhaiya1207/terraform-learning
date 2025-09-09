locals {
  local_public_subnets = {
    for key, config in var.subnet_config : key => config if config.public
  }

  local_private_subnets = {
    for key, config in var.subnet_config : key => config if !config.public
  }

}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block

  tags = merge(local.common_tags, {
    Name = "${local.common_tags.Project}-VPC"
  })
}

resource "aws_subnet" "this" {
  for_each          = var.subnet_config
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  vpc_id            = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name   = "${local.common_tags.Project}-${each.key}"
    Access = each.value.public ? "public" : "private"
  })

}


resource "aws_internet_gateway" "igw" {
  count  = length(local.local_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

}


resource "aws_route_table" "public_rtb" {
  count  = length(local.local_public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
}


resource "aws_route_table_association" "public_subnet_association" {
  for_each       = local.local_public_subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public_rtb[0].id
}