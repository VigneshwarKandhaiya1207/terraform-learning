variable "create" {
  type    = bool
  default = true
}

variable "client_name" {
  description = "Name prefix for VPC resources (unique per VPC)"
  type        = string
}

variable "Env" {
  description = "Name of the Environment"
  type        = string
}

variable "application" {
  description = "Name of the application"
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "s3_bucket_name" {
  description = "S3 bucket for static content"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate"
  type        = string
}

variable "aliases" {
  description = "Custom domain aliases for CloudFront"
  type        = list(string)
  default     = []
}
