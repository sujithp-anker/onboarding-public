variable "CustomerName" {
  type        = string
  description = "Name of the Client"
}

variable "CustomerAccountId" {
  type        = string
  description = "12-digit AWS Account ID"
}

variable "CrossAccountAssumeRoleARN" {
  type        = string
  default     = ""
  description = "Cross Account IAM Role ARN to assume. Leave this blank if using credentials (Add them via Credentials tab)"
}

variable "ENABLE_SNS_alerts" {
  type        = bool
  default     = false
  description = "⚠️ Deploy SNS Topic (true/false) "
}

variable "AlertEmail" {
  type        = string
  default     = ""
  description = "Email for notifications (Required if EnableAlerts is true)"
}

variable "ENABLE_MFAEnforcement" {
  type        = bool
  default     = false
  description = "⚠️ Create MFA enforcement group (true/false); Users need to be added manually"
}

variable "ENABLE_PasswordPolicy" {
  type        = bool
  default     = false
  description = "⚠️ Set 90-day password rotation policy (true/false) "
}

variable "SET_BudgetLimit" {
  type        = string
  default     = "100"
  description = "Monthly limit in USD"
}

variable "ENABLE_BudgetThreshold_Actual_50" {
  type        = bool
  default     = false
  description = "⚠️ Alert when actual spend hits 50% (true/false)"
}

variable "ENABLE_BudgetThreshold_Actual_75" {
  type        = bool
  default     = false
  description = "⚠️ Alert when actual spend hits 75% (true/false)"
}

variable "ENABLE_BudgetThreshold_Actual_100" {
  type        = bool
  default     = true
  description = "⚠️ Alert when actual spend hits 100% (true/false)"
}

variable "ENABLE_BudgetThreshold_Forecast_100" {
  type        = bool
  default     = false
  description = "⚠️ Alert if forecasted spend hits 100% (true/false)"
}