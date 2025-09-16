# output "cloudfront_domain_name" {
#   value = try(aws_cloudfront_distribution.this[0].domain_name, null)
# }

# output "s3_bucket_name" {
#   value = try(aws_s3_bucket.this[0].bucket, null)
# }

# output "alias_cname" {
#   description = "Manual CNAME record for CloudFront alias"
#   value = try({
#     name  = var.aliases[0]
#     type  = "CNAME"
#     value = aws_cloudfront_distribution.this[0].domain_name
#   }, null)
# }


output "cloudfront_distribution_id" {
  value = try(one(aws_cloudfront_distribution.this[*].id), null)
}

output "cloudfront_domain_name" {
  value = try(one(aws_cloudfront_distribution.this[*].domain_name), null)
}