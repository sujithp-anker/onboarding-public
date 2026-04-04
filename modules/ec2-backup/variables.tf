variable "customer_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "The environment tag (Prod/Stage) used for backup logic."
}