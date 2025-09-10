# output "module_vpc_id" {
#   value = module.module_network.vpc_id

# }

# output "module_public_subnet" {
#   value = module.module_network.public_subnets
# }

# output "module_private_subnets" {
#   value = module.module_network.private_subnets
# }

output "client_subnets" {
  value = module.client_network.subnet_flattened
  
}

output "client_public_subnets" {
  value = module.client_network.module_public_subnet
}

output "client_private_subnets" {
  value = module.client_network.module_private_subnet
}