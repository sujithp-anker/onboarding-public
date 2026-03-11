variable "_00_customer_name" {
  type        = string
  description = "IDENTITY: Legal Name of the Client"
}

variable "_00_customer_account_id" {
  type        = string
  description = "IDENTITY: 12-digit AWS Account ID"
}

variable "_01_enable_alerts" {
  type        = bool
  default     = false
  description = "ALERTS: (true/false) Deploy SNS Topic"
}

variable "_01_alert_email" {
  type        = string
  default     = ""
  description = "ALERTS: Email for notifications (Required if 01_enable is true)"
}

variable "_02_enable_mfa_enforcement" {
  type        = bool
  default     = false
  description = "IAM: (true/false) Create MFA enforcement group"
}

variable "_02_enable_password_policy" {
  type        = bool
  default     = false
  description = "IAM: (true/false) Set 90-day password rotation policy"
}