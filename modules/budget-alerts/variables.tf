variable "customer_name" {
  type        = string
  description = "The name of the customer for naming the budget resource."
}

variable "budget_limit" {
  type        = string
  description = "The total monthly budget limit in USD."
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic to send alerts to."
}

variable "actual_thresholds" {
  type        = string
  description = "Comma separated list of thresholds"
}

variable "enable_forecasted_100" {
  type        = bool
  default     = false
  description = "Toggle for the 100% forecasted spend notification"
}