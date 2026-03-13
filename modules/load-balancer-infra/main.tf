data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "elb_logs" {
  bucket        = "${var.customer_name}-elb-logs-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.elb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.elb_logs.arn}/AWSLogs/${var.account_id}/*"
      }
    ]
  })
}

resource "aws_athena_database" "elb_db" {
  name   = "${replace(var.customer_name, "-", "_")}_elb_db"
  bucket = aws_s3_bucket.elb_logs.id
}

resource "aws_athena_named_query" "create_table" {
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
LOCATION 's3://${aws_s3_bucket.elb_logs.id}/AWSLogs/${var.account_id}/elasticloadbalancing/${var.region}/'
TBLPROPERTIES (
    "projection.enabled" = "true",
    "projection.day.type" = "date",
    "projection.day.range" = "2024/01/01,NOW",
    "projection.day.format" = "yyyy/MM/dd",
    "storage.location.template" = "s3://${aws_s3_bucket.elb_logs.id}/AWSLogs/${var.account_id}/elasticloadbalancing/${var.region}/$${day}"
)
EOF
}