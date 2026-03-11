variable "customer_name" {
  type        = string
  default     = "AcmeCorp"
  description = "The Legal Name of the Client (e.g., AcmeCorp)"
}

variable "alert_email" {
  type        = string
  default     = "user@acmecorp.com"
  description = "Primary email for notifications"
}

variable "customer_account_id" {
  type        = string
  default     = "123456789123"
  description = "The 12-digit AWS Account ID to provision into"
}

variable "enable_alerts" {
  type        = bool
  default     = true
  description = "Enter true to enable & false to disable alerts"
}