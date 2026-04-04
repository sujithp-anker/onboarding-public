variable "customer_name" {
  type        = string
  description = "The name of the customer to prefix the IAM resources."
}

variable "enable_mfa" {
  type        = bool
  default     = false
  description = "Whether to create the MFA enforcement group and policy."
}

variable "enable_password_policy" {
  type        = bool
  default     = false
  description = "Whether to apply the 90-day password rotation policy to the account."
}

variable "enable_monitoring" { type = bool }