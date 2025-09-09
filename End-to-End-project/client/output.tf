output "module_vpc_id" {
  value = module.module_network.vpc_id

}

output "module_public_subnet" {
  value = module.module_network.public_subnets
}

output "module_private_subnets" {
  value = module.module_network.private_subnets
}