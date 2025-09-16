output "certificate_arn" {
  value = try(aws_acm_certificate.this[0].arn, null)
}

output "validation_cnames" {
  description = "Manual CNAME records for DNS validation"
  value = try([
    for dvo in aws_acm_certificate.this[0].domain_validation_options : {
      domain = dvo.domain_name
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  ], [])
}
