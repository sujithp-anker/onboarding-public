# variable "customer_name" {
#   type        = string
#   description = "Name used for the Parameter Group and resource naming."
# }

variable "db_instance_ids" {
  type        = list(string)
  description = "List of existing RDS Instance Identifiers to modify."
}

variable "environment" {
  type        = string
  description = "Used to determine backup retention (Prod: 35d, Stage: 7d)."
}

variable "region" {
  type = string
}