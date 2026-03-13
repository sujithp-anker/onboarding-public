variable "customer_name" {
  type        = string
  description = "The name of the customer for bucket naming (e.g., 'acme')."
}

variable "account_id" {
  type        = string
  description = "The 12-digit AWS Account ID (required for the S3 bucket policy)."
}

variable "region" {
  type        = string
  description = "The AWS region where logs are stored (e.g., 'us-east-1')."
}

variable "environment" {
  type        = string
  description = "Environment type: 'Prod' (30d retention) or 'Stage' (7d retention)."
}