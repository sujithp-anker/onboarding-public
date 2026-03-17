variable "customer_name" {
  type        = string
  description = "Name used to prefix the CloudWatch Dashboard and Alarms."
}

variable "db_instance_ids" {
  type        = list(string)
  description = "List of existing RDS Instance Identifiers to monitor."
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic for alarm notifications."
}

variable "region" {
  type        = string
  description = "The AWS region where the RDS instances reside (needed for Dashboard JSON)."
}

variable "environment" {
  type        = string
  description = "Environment tag (Prod/Stage) used for naming and logic."
}