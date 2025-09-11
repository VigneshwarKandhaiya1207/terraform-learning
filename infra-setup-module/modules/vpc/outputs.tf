output "module_private_subnet" {
  value = local.local_private_subnets
}

output "module_public_subnet" {
  value = local.local_public_subnets
}

output "module_private_subnet_count" {
  value = local.private_subnet_count
}

output "module_public_subnet_count" {
  value = local.public_subnet_count
}
