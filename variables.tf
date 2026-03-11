variable "CustomerName" {
  type        = string
  description = "Name of the Client"
}

variable "CustomerAccountId" {
  type        = string
  description = "12-digit AWS Account ID"
}

variable "EnableAlerts" {
  type        = bool
  default     = false
  description = "Deploy SNS Topic (true/false) "
}

variable "AlertEmail" {
  type        = string
  default     = ""
  description = "Email for notifications (Required if EnableAlerts is true)"
}

variable "EnableMFAEnforcement" {
  type        = bool
  default     = false
  description = "Create MFA enforcement group (true/false)"
}

variable "EnablePasswordPolicy" {
  type        = bool
  default     = false
  description = "Set 90-day password rotation policy (true/false) "
}