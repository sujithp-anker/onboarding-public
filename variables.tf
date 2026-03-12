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

variable "ENABLE_SNSAlert" {
  type        = bool
  default     = false
  description = "Deploy SNS Topic for alerts "
}

variable "AlertEmail" {
  type        = string
  default     = ""
  description = "Email for notifications (Required if EnableAlerts is true)"
}

variable "ENABLE_MFAEnforcement" {
  type        = bool
  default     = false
  description = "Create MFA enforcement group; Users need to be added to the group manually"
}

variable "ENABLE_PasswordPolicy" {
  type        = bool
  default     = false
  description = "Set 90-day password rotation policy"
}

variable "SET_BudgetLimit" {
  type        = string
  default     = ""
  description = "Actual budget limit in USD"
}

variable "SET_BudgetActualThresholds" {
  type        = string
  default     = ""
  description = "Enter percentages for ACTUAL spend alerts (comma separated e.g 50,75,100). Leave blank to disable"
}

variable "ENABLE_BudgetForecast100" {
  type        = bool
  default     = false
  description = "Enable alert for 100% FORECASTED spend?"
}

variable "ENABLE_CloudTrailLogs" {
  type        = bool
  default     = false
  description = "Enable CloudTrail logs account-wide with 90-day retention"
}

variable "ENABLE_EC2Backup" {
  type        = bool
  default     = false
  description = "Create backup plan for prod-backup (7-days retention) and stg-backup (3-days retention) environment. Manually attach the tags with prod-backup/stg-backup with true values."
}

variable "ENABLE_StatusCheckAlarmsForInstances" {
  type        = string
  default     = ""
  description = "Comma-separated list of existing Instance IDs to add Status Check Alarms"
}