variable "customer_name" {
  type        = string
  description = "Name used to prefix the CloudWatch Dashboard and Alarms."
}

variable "enable_resource_tagging_automation" {
  type    = bool
  default = false
}