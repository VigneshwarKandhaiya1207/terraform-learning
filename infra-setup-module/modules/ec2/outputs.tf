# output "app_instance_id" {
#   value = try(aws_instance.app[0].id, null)
# }

# output "app_private_ip" {
#   value = try(aws_instance.app[0].private_ip, null)
# }

# output "mysql_instance_id" {
#   value = try(aws_instance.mysql[0].id, null)
# }

# output "mysql_private_ip" {
#   value = try(aws_instance.mysql[0].private_ip, null)
# }

# output "app_sg_id" {
#   value = try(aws_security_group.app_sg[0].id, null)
# }

# output "mysql_sg_id" {
#   value = try(aws_security_group.mysql_sg[0].id, null)
# }

output "app_instance_id" {
  value = try(aws_instance.app["app"].id, null)
}

output "mysql_instance_id" {
  value = try(aws_instance.mysql["mysql"].id, null)
}

output "app_sg_id" {
  value = try(aws_security_group.app_sg["app"].id, null)
}

output "mysql_sg_id" {
  value = try(aws_security_group.mysql_sg["mysql"].id, null)
}