locals {
  common_tags = {
    BSN         = "${var.client_name}"
    Env         = "${var.Env}"
    Cost-Center = "${var.client_name}-${var.Env}"
  }
}



resource "aws_s3_bucket" "this" {
  count  = var.create ? 1 : 0
  bucket = var.s3_bucket_name

  tags = merge(local.common_tags, {
    Name = var.s3_bucket_name
  })
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.this[0].arn}/*"
      }
    ]
  })
}

# ---------------------------
# CloudFront
# ---------------------------
resource "aws_cloudfront_distribution" "this" {
  count = var.create ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id   = "s3-origin"
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-cloudfront"
  })
}
