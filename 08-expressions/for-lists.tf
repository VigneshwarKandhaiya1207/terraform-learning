locals {
  double_number = [for num in var.number_list : num * 2]
  even_number   = [for num in var.number_list : num * 3 if num % 2 == 0]
  firstname     = [for person in var.object_list : person.firstname]
  fullname      = [for person in var.object_list : "${person.firstname} ${person.lastname}"]
}

output "double_number" {
  value = local.double_number
}

output "even_number" {
  value = local.even_number
}

output "firstname" {
  value = local.firstname
}

output "fullname" {
  value = local.fullname
}