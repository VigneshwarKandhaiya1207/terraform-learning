locals {
  double_map = { for key, value in var.number_map : key => value * 2 }
  even_map   = { for key, value in var.number_map : key => value if value % 2 == 0 }


}

output "double_map" {
  value = local.double_map
}

output "even_map" {
  value = local.even_map
}