resource "aws_route53_zone" "this" {
  name          = var.domain_name
  comment       = var.comment
  force_destroy = false

  lifecycle {
    ignore_changes = [vpc]
  }
}

module "website" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.0.0"

  bucket_name        = aws_route53_zone.this.name
  bucket_key_enabled = true
  context            = module.this.context
}

module "www-website" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.0.0"

  bucket_name        = format("www.%s", aws_route53_zone.this.name)
  bucket_key_enabled = true
  context            = module.this.context
}