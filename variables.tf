variable "domain_name" {
  type        = string
  description = "Hosted Zone domain name"
}

variable "comment" {
  type        = string
  description = "Hosted Zone comment"
}

variable "caa_report_recipient" {
  type    = string
  default = null
}

variable "tls_report_recipient" {
  type    = string
  default = null
}

variable "sts_policy_mode" {
  type    = string
  default = "testing"
}

variable "mx_records" {
  type    = list(string)
  default = []
}