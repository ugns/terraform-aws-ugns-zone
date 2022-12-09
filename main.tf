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
  website_configuration = [{
    error_document = "/404.html"
    index_document = "index.html"
    routing_rules = [{
      condition = {
        http_error_code_returned_equals = null
        key_prefix_equals               = null
      }
      redirect = {
        host_name               = null
        http_redirect_code      = null
        protocol                = null
        replace_key_prefix_with = null
        replace_key_with        = null
      }
    }]
  }]
  context = module.this.context
}

module "www-website" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.0.0"

  bucket_name        = format("www.%s", aws_route53_zone.this.name)
  bucket_key_enabled = true
  website_redirect_all_requests_to = [{
    host_name = aws_route53_zone.this.name
    protocol  = "https"
  }]
  context = module.this.context
}

module "acm_request_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.17.0"

  domain_name                       = aws_route53_zone.this.name
  zone_id                           = aws_route53_zone.this.zone_id
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = [format("*.%s", aws_route53_zone.this.name)]
  context                           = module.this.context
}