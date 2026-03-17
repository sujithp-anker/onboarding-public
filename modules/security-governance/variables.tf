variable "customer_name" { type = string }
variable "sns_topic_arn" { type = string }

variable "acm_days_to_expiration" {
  type        = number
  default     = 30
  description = "Number of days before expiry to trigger the alarm."
}