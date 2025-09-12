# output "client_private_subnets" {
#   value = module.app_vpc.module_private_subnet
# }

# output "client_public_subnets" {
#   value = module.app_vpc.module_public_subnet
# }

# output "client_private_subnet_counts" {
#   value = module.app_vpc.module_private_subnet_count
# }

# output "client_public_subnet_counts" {
#   value = module.app_vpc.module_public_subnet_count
# }


# Output to CLI
# output "infra_summary_text" {
#   description = "Consolidated infra summary for all VPCs"
#   value       = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
# }

# # Optional: write to disk
# resource "local_file" "infra_summary_file" {
#   content  = templatefile("${path.module}/templates/infra-summary.tmpl", { vpcs = local.all_vpcs })
#   filename = "${path.module}/infra-summary.txt"
# }
