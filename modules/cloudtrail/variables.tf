variable "customer_name" {
  type        = string
  description = "The name of the customer used for resource naming and S3 bucket prefixing."
}

variable "account_id" {
  type        = string
  description = "The 12-digit AWS Account ID (required for S3 bucket policy and trail pathing)."
}