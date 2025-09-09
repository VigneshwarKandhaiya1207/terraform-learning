locals {
  user_map = { for user_info in var.user : user_info.username => user_info.role... }

  user_map_2 = { for username, roles in local.user_map : username => {
    roles = roles
    }

  }
}

output "user_map" {
  value = local.user_map

}

output "user_map_2" {
  value = local.user_map_2

}

output "user_to_show" {
  value = local.user_map_2[var.user_to_output].roles
}


