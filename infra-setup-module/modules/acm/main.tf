provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

locals {
  common_tags = {
    BSN         = "${var.client_name}"
    Env         = "${var.Env}"
    Cost-Center = "${var.client_name}-${var.Env}"
  }
}

resource "aws_acm_certificate" "this" {
  provider                  = aws.us_east_1
  count                     = var.create ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = merge(local.common_tags, {
    Name = "${var.domain_name}-cert"
  })
}
