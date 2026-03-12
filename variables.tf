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
  description = "Cross Account IAM Role ARN to assume. Leave this blank if using credentials (Add them via Credentials tab). --- Download and deploy the CFT stack to provision cross account role."
}

variable "ENABLE_SNSAlert" {
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
  description = "⚠️ Create MFA enforcement group (true/false); Users need to be added to the group manually"
}

variable "ENABLE_PasswordPolicy" {
  type        = bool
  default     = false
  description = "⚠️ Set 90-day password rotation policy (true/false) "
}

variable "SET_BudgetLimit" {
  type        = string
  default     = ""
  description = "Actual budget limit in USD"
}

variable "SET_BudgetActualThresholds" {
  type        = string
  default     = ""
  description = "⚠️ Enter percentages for ACTUAL spend alerts (comma separated e.g 50,75,100). Leave blank to disable"
}

variable "ENABLE_BudgetForecast100" {
  type        = bool
  default     = false
  description = "⚠️ Enable alert for 100% FORECASTED spend? (true/false)"
}