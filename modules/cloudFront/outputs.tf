output "cloudfront_url" {
  value = aws_cloudfront_distribution.tbc-distribution.domain_name
}