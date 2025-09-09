output "bucket_endpoint" {
  value = aws_s3_bucket_website_configuration.static_website_configuration.website_endpoint
}