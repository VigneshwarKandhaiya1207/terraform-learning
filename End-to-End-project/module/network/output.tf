# output "vpc_id" {
#   value = aws_vpc.this.id
# }

output "subnet_flattened" {
  value = local.all_subnets
}

output "module_public_subnet" {
  value = local.public_subnets
}

output "module_private_subnet" {
  value = local.private_subnets
}

# locals {
#   output_public_subnet = {
#     for key in keys(local.local_public_subnets) : key => {
#       subnet_id         = aws_subnet.this[key].id
#       availability_zone = aws_subnet.this[key].availability_zone

#     }
#   }


#   output_private_subnet = {
#     for key in keys(local.local_private_subnets) : key => {
#       subnet_id         = aws_subnet.this[key].id
#       availability_zone = aws_subnet.this[key].availability_zone

#     }
#   }
# }
# output "public_subnets" {
#   value = local.output_public_subnet
# }

# output "private_subnets" {
#   value = local.output_private_subnet
# }

# resource "local_file" "vpc_output_txt" {
#   filename = "${path.module}/vpc_output.txt"
#   content = <<-EOT
#   VPC DETAILS:

#   VPC ID : ${aws_vpc.this.id}
#     Public Subnets:
#     %{for name, subnet in aws_subnet.this~}
#     %{if lookup(local.local_public_subnets, name, null) != null~}
#     - ${name}:
#       * ID: ${subnet.id}
#       * CIDR: ${subnet.cidr_block}
#       * AZ: ${subnet.availability_zone}
#     %{endif~}
#     %{endfor~}

#     Private Subnets:
#     %{for name, subnet in aws_subnet.this~}
#     %{if lookup(local.local_private_subnets, name, null) != null~}
#     - ${name}:
#       * ID: ${subnet.id}
#       * CIDR: ${subnet.cidr_block}
#       * AZ: ${subnet.availability_zone}
#     %{endif~}
#     %{endfor~} 

# EOT 
# }