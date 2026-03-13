variable "customer_name" {
  type        = string
}

variable "lb_names" {
  type        = list(string)
  description = "List of existing ALB names."
}

variable "tg_names" {
  type        = list(string)
  description = "List of existing Target Group names."
}

variable "sns_topic_arn" {
  type        = string
}