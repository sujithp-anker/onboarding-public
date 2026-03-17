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

variable "Region" { 
  type = string
  default = "us-east-1"
  description = "AWS Region where the workloads are located"
}

variable "EnvironmentTag" {
  type        = string
  default     = "Stage"
  description = "Used for retention logic. 'Prod' (30 days) or 'Stage' (7 days)."
}

variable "ENABLE_SNSAlert" {
  type        = bool
  default     = false
  description = "Deploy SNS Topic for alerts "
}

variable "AlertEmail" {
  type        = string
  default     = ""
  description = "Email for notifications (Required if ENABLE_SNSAlert is true)"
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
  description = "Provisions a Backup Vault and Plan. Applies a 7-day retention policy to resources tagged prod-backup: true and a 3-day policy to those tagged stg-backup: true"
}

variable "ENABLE_StatusCheckAlarmsForInstances" {
  type        = string
  default     = ""
  description = "Comma-separated list of existing Instance IDs to add Status Check Alarms"
}

variable "ENABLE_ELBLogsAnalyzeInfra" {
  type        = bool
  default     = false
  description = "Create S3 Logging Bucket and Athena Analysis Database"
}

variable "ENABLE_LBMonitoring" {
  type        = string
  default     = ""
  description = "Comma-separated list of existing ALB names (e.g., 'lb-prod, lb-stage')"
}

variable "ENABLE_TGMonitoring" {
  type        = string
  default     = ""
  description = "Comma-separated list of Target Group names (e.g., 'tg-prod-app, tg-stage-app')"
}

variable "EnableVPCFlowLogs" {
  type        = bool
  default     = false
  description = "Enable Flow Logs for the specified VPC Names"
}

variable "VPCNames" {
  type        = string
  default     = ""
  description = "Comma-separated list of VPC Name tags (e.g., 'VPC-Prod, VPC-Stage')"
}