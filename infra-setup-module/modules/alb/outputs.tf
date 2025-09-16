# # ---------------------------
# # Outputs
# # ---------------------------
# output "alb_arn" {
#   value = try(aws_lb.this[0].arn, null)
# }

# output "alb_dns_name" {
#   value = try(aws_lb.this[0].dns_name, null)
# }

# output "alb_zone_id" {
#   value = try(aws_lb.this[0].zone_id, null)
# }

# output "alb_sg_id" {
#   value = try(aws_security_group.alb_sg[0].id, null)
# }

# output "target_group_arn" {
#   value = try(aws_lb_target_group.this[0].arn, null)
# }


output "alb_sg_id" {
  value = try(aws_security_group.alb_sg["alb"].id, null)
}

output "alb_arn" {
  value = try(aws_lb.this["alb"].arn, null)
}

output "alb_dns_name" {
  value = try(aws_lb.this["alb"].dns_name, null)
}

output "target_group_arn" {
  value = try(aws_lb_target_group.this["tg"].arn, null)
}
