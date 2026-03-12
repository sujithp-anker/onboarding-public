variable "customer_name" {
  type        = string
  description = "Name of the customer for naming conventions."
}

variable "instance_ids" {
  type        = list(string)
  description = "List of existing EC2 Instance IDs to onboard."
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic for alerts."
}