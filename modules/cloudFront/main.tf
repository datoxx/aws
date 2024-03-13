resource "aws_cloudfront_distribution" "tbc-distribution" {
  origin {
    domain_name = var.s3.bucket_regional_domain_name
    origin_id   = var.s3.id
  }


    viewer_certificate {
        cloudfront_default_certificate = true
    }


  default_cache_behavior {
    target_origin_id   = var.s3.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    default_ttl     = 3600
    min_ttl         = 0
    max_ttl         = 86400

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Example CloudFront Distribution"
  default_root_object = var.key
  price_class         = "PriceClass_100"
}
