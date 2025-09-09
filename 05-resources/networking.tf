locals {
  common_tags = {
    ManagedBy = "Terraform"
    Project   = "05-resources"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "05-resources-main"
  })
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.0.0/24"
  vpc_id     = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "05-resources-public"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "05-resources-igw"
  })

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name       = "05-resources-public-route-table"
    Costcenter = "vignesh-testing"
  })
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}