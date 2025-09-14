output "map_alb_dns" {
  value = try(module.map_alb.alb_dns_name, null)
}

output "cwb_alb_dns" {
  value = try(module.cwb_alb.alb_dns_name, null)
}

output "vpc_summary" {
  value = module.app_vpc.vpc_info
}
