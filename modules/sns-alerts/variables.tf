variable "customer_name" {
  type        = string
  description = "Name used for naming the SNS topic"
}

variable "alert_email" {
  type        = string
  description = "Email address to receive the AWS notifications"
}