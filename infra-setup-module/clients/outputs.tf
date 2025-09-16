output "map_alb_dns" {
  value = try(module.map_alb.alb_dns_name, null)
}

output "cwb_alb_dns" {
  value = try(module.cwb_alb.alb_dns_name, null)
}

output "vpc_summary" {
  value = module.app_vpc.vpc_info
}

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}

output "acm_validation_records" {
  value = module.acm.validation_cnames
}

output "mdm_cloudfront_details" {
  value = {
    cloudfront_domain = try(module.map_cloudfront.cloudfront_domain_name, null)
    s3_bucket         = try(module.map_cloudfront.s3_bucket_name, null)
    cname_alias       = try(module.map_cloudfront.alias_cname, null)
  }
}
