data "aws_elb_service_account" "main" {}

data "aws_lb" "selected" {
  for_each = toset(var.lb_names)
  name     = each.value
}

resource "aws_s3_bucket" "elb_logs" {
  bucket        = "${var.customer_name}-elb-logs-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "retention" {
  bucket = aws_s3_bucket.elb_logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"
    expiration {
      days = var.environment == "Prod" ? 30 : 7
    }
  }
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowELBServiceAccount"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.elb_logs.id}/ELBLogs/AWSLogs/${var.account_id}/*"
      },
      {
        Sid    = "AllowLogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.elb_logs.id}/ELBLogs/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

resource "null_resource" "enable_lb_logging" {
  for_each = toset(var.lb_names)

  triggers = {
    lb_arn = data.aws_lb.selected[each.value].arn
    bucket = aws_s3_bucket.elb_logs.id
  }

  provisioner "local-exec" {
    command = <<EOT
      aws elbv2 modify-load-balancer-attributes \
      --load-balancer-arn ${data.aws_lb.selected[each.value].arn} \
      --attributes Key=access_logs.s3.enabled,Value=true Key=access_logs.s3.bucket,Value=${aws_s3_bucket.elb_logs.id} Key=access_logs.s3.prefix,Value=ELBLogs
    EOT
  }

  depends_on = [aws_s3_bucket_policy.allow_elb_logging]
}

resource "aws_athena_database" "elb_db" {
  name   = "${replace(var.customer_name, "-", "_")}_elb_logs_db"
  bucket = aws_s3_bucket.elb_logs.id
}

resource "aws_athena_named_query" "create_alb_logs_table" {
  name     = "create-alb-logs-table"
  database = aws_athena_database.elb_db.name
  query    = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS alb_logs (
    type string, time string, elb string, client_ip string, client_port int,
    target_ip string, target_port int, request_processing_time double,
    target_processing_time double, response_processing_time double,
    elb_status_code int, target_status_code int, received_bytes bigint,
    sent_bytes bigint, request string, user_agent string, ssl_cipher string,
    ssl_protocol string, target_group_arn string, trace_id string,
    domain_name string, chosen_cert_arn string, matched_rule_priority int,
    request_creation_time string, leveraged_lb_alias_target string,
    error_reason string, target_port_list string, target_status_code_list string,
    classification string, classification_reason string
)
PARTITIONED BY (day string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    'serialization.format' = '1',
    'input.regex' = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) ([^ ]*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\"$'
)
LOCATION 's3://${aws_s3_bucket.elb_logs.id}/ELBLogs/AWSLogs/${var.account_id}/elasticloadbalancing/${var.region}/'
TBLPROPERTIES (
    "projection.enabled" = "true",
    "projection.day.type" = "date",
    "projection.day.range" = "2024/01/01,NOW",
    "projection.day.format" = "yyyy/MM/dd",
    "projection.day.interval" = "1",
    "projection.day.interval.unit" = "DAYS",
    "storage.location.template" = "s3://${aws_s3_bucket.elb_logs.id}/ELBLogs/AWSLogs/${var.account_id}/elasticloadbalancing/${var.region}/$${day}"
)
EOF
}