variable "customer_name" {
  type        = string
  description = "Used for naming consistency in lifecycle rules or tags."
}

variable "s3_bucket_names" {
  type        = list(string)
  description = "List of existing S3 bucket names. Passed from root via split()."
}

variable "environment" {
  type        = string
  description = "Used to vary lifecycle logic (e.g., Prod vs Stage retention)."
}

variable "noncurrent_version_glacier_days" {
  type        = number
  default     = 30
  description = "Days before non-current versions move to Glacier."
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 90
  description = "Days before non-current versions are permanently deleted."
}