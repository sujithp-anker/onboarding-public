variable "customer_name" {
  type = string
}

variable "enable_password_rotation" {
  type    = bool
  default = false
}

variable "enable_iam_access_analyzer" {
  type    = bool
  default = false
}