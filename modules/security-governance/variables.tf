variable "customer_name" { type = string }
variable "sns_topic_arn" { type = string }

variable "enable_public_ports_alerts" {
  type    = bool
  default = false
}

variable "enable_ssl_expiry_alerts" {
  type    = bool
  default = false
}

variable "acm_days_to_expiration" {
  type    = number
  default = 30
}

variable "enable_health_dashboard" {
  type    = bool
  default = false
}

variable "enable_global_cloudtrail_logs" {
  type    = bool
  default = false
}

variable "cloudtrail_s3_bucket_name" {
  type    = string
  default = ""
}