variable "customer_name" {
  type        = string
  default     = "test-customer"
  description = "The Legal Name of the Client (e.g., AcmeCorp)"
}

variable "alert_email" {
  type        = string
  default     = "example@example.com"
  description = "Primary email for notifications"
}

variable "customer_account_id" {
  type        = string
  default     = "test-customer"
  description = "The 12-digit AWS Account ID to provision into"
}

variable "enable_phase_1_alerts" {
  type        = bool
  default     = true
  description = "ON: Deploy Phase 1 (Email Alerts). OFF: No alerts."
}