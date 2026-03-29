variable "customer_name" { type = string }
variable "vpc_names" {
  type        = list(string)
  default     = ""
  description = "Comma-separated list of VPC Name tags (e.g., 'VPC-Prod, VPC-Stage')."
  
}
variable "environment"   { type = string }