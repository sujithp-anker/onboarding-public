terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_s3_bucket" "selected" {
  for_each = toset(var.s3_bucket_names)
  bucket   = each.value
}

resource "aws_s3_bucket_public_access_block" "governance" {
  for_each = toset(var.s3_bucket_names)
  bucket   = data.aws_s3_bucket.selected[each.value].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "governance" {
  for_each = toset(var.s3_bucket_names)
  bucket   = data.aws_s3_bucket.selected[each.value].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "governance" {
  for_each = toset(var.s3_bucket_names)
  bucket   = data.aws_s3_bucket.selected[each.value].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "governance" {
  for_each = toset(var.s3_bucket_names)
  bucket   = data.aws_s3_bucket.selected[each.value].id

  rule {
    id     = "archive-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_glacier_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }
}