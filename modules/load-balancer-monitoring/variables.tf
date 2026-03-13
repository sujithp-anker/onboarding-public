variable "customer_name" {
  type        = string
  description = "The name of the customer to prefix the alarm names."
}

variable "lb_name" {
  type        = string
  description = "The exact name of the existing Application Load Balancer."
}

variable "tg_name" {
  type        = string
  description = "The exact name of the existing Target Group."
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic where alerts will be sent."
}