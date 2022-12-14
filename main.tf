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
    routing_rules  = []
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

module "caa" {
  source  = "UGNS/route53-caa/aws"
  version = "0.1.1"

  zone_id              = aws_route53_zone.this.zone_id
  caa_report_recipient = var.caa_report_recipient
}

module "ses" {
  source  = "UGNS/route53-ses/aws"
  version = "0.1.1"

  zone_id = aws_route53_zone.this.zone_id
}

module "mta-sts" {
  source  = "UGNS/route53-mta-sts/aws"
  version = "0.1.1"

  zone_id              = aws_route53_zone.this.zone_id
  tls_report_recipient = var.tls_report_recipient
  sts_policy_mode      = var.sts_policy_mode
  mx_records           = var.mx_records
}

module "dnssec" {
  source  = "UGNS/route53-dnssec/aws"
  version = "1.1.0"

  zones = {
    this = {
      zone_id = aws_route53_zone.this.zone_id
    }
  }
}
