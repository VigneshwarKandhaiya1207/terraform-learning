# -----------------------------
# Individual outputs for subnets, IGW, NAT, RTs, S3 endpoint
# -----------------------------
output "vpc_id" {
  value = aws_vpc.this.id
}

output "cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  value = {
    for k, s in aws_subnet.this :
    k => {
      id         = s.id
      cidr_block = s.cidr_block
      az         = s.availability_zone
    } if lookup(var.subnets[k], "public", false)
  }
}

output "private_subnets" {
  value = {
    for k, s in aws_subnet.this :
    k => {
      id         = s.id
      cidr_block = s.cidr_block
      az         = s.availability_zone
    } if !lookup(var.subnets[k], "public", false)
  }
}

output "internet_gateway_id" {
  value = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_id" {
  value = try(aws_nat_gateway.nat[0].id, null)
}

output "public_route_table_id" {
  value = try(aws_route_table.public[0].id, null)
}

output "private_route_table_ids" {
  value = {
    for rt in aws_route_table.private :
    rt.tags.Name => rt.id
  }
}

output "s3_endpoint_id" {
  value = try(aws_vpc_endpoint.s3[0].id, null)
}

# -----------------------------
# Combined object for easy reference
# -----------------------------
output "vpc_info" {
  description = "All important details about this VPC"
  value = {
    vpc_id              = aws_vpc.this.id
    cidr_block          = aws_vpc.this.cidr_block
    public_subnets      = { for k, s in aws_subnet.this : k => s.id if lookup(var.subnets[k], "public", false) }
    private_subnets     = { for k, s in aws_subnet.this : k => s.id if !lookup(var.subnets[k], "public", false) }
    internet_gateway_id = try(aws_internet_gateway.this[0].id, "")
    nat_gateway_id      = try(aws_nat_gateway.nat[0].id, "")
    public_rt_id        = try(aws_route_table.public[0].id, "")
    private_rt_ids      = { for rt in aws_route_table.private : rt.tags.Name => rt.id }
    s3_endpoint_id      = try(aws_vpc_endpoint.s3[0].id, "")
  }
}
