variable "customer_name" {
  type        = string
  description = "Project or Customer name for prefixing."
}

variable "db_instance_ids" {
  type        = list(string)
  description = "List of RDS identifiers."
}

variable "sns_topic_arn" {
  type        = string
}

variable "region" {
  type        = string
}

variable "environment" {
  type        = string
}