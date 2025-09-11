output "client_private_subnets" {
  value = module.app_vpc.module_private_subnet
}

output "client_public_subnets" {
  value = module.app_vpc.module_public_subnet
}

output "client_private_subnet_counts" {
  value = module.app_vpc.module_private_subnet_count
}

output "client_public_subnet_counts" {
  value = module.app_vpc.module_public_subnet_count
}
