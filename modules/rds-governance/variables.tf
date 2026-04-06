variable "customer_name" {
  type        = string
  description = "Name used for the Parameter Group and resource naming."
}

variable "db_instance_ids" {
  type        = list(string)
  description = "List of existing RDS Instance Identifiers to modify."
}

variable "environment" {
  type        = string
  description = "Used to determine backup retention (Prod: 35d, Stage: 7d)."
}

variable "enable_storage_autoscaling" {
  type        = bool
  default     = true
  description = "Toggle to enable Storage Autoscaling via CLI."
}

variable "max_allocated_storage" {
  type        = number
  default     = 1000
  description = "Upper limit for storage autoscaling (in GB)."
}

variable "enable_alarms"   { type = bool }

variable "sns_topic_arn"   { type = string }