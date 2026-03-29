resource "aws_cloudwatch_log_group" "trail_logs" {
  name              = "/aws/cloudtrail/${var.customer_name}-trail"
  retention_in_days = 90
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "${var.customer_name}-cloudtrail-logs-${var.account_id}"
  force_destroy = true
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  name = "${var.customer_name}-CloudTrailToCloudWatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "cloudwatch_delivery" {
  name = "CloudWatchDeliveryPolicy"
  role = aws_iam_role.cloudtrail_to_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.customer_name}-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail_logs.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch.arn

  depends_on = [aws_s3_bucket_policy.allow_cloudtrail]
}

resource "aws_s3_bucket_policy" "allow_cloudtrail" {
  bucket = aws_s3_bucket.trail_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.trail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.trail_bucket.arn}/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}