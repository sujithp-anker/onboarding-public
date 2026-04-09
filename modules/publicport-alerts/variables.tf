variable "enable_public_ports_alerts" {
  description = "If true, checks for SGs with open ports other than 80/443 and alerts via SNS."
  type        = bool
  default     = false
}

variable "customer_name" { type = string }

variable "sns_topic_arn" {
  type        = string
}

variable "region" {
  type = string
}