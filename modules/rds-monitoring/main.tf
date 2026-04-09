terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_db_instance" "selected" {
  for_each               = toset(var.db_instance_ids)
  db_instance_identifier = each.value
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-cpu-high-${each.value}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { DBInstanceIdentifier = each.value }
}

resource "aws_cloudwatch_metric_alarm" "storage_low" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-storage-low-${each.value}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = data.aws_db_instance.selected[each.value].allocated_storage * 1073741824 * 0.2
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { DBInstanceIdentifier = each.value }
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-memory-low-${each.value}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000000"
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { DBInstanceIdentifier = each.value }
}

resource "aws_cloudwatch_metric_alarm" "latency_high" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-latency-high-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadLatency" 
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { DBInstanceIdentifier = each.value }
}

resource "aws_cloudwatch_metric_alarm" "throughput_anomaly" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-read-throughput-anomaly-${each.value}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "2"
  threshold_metric_id = "ad1"

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "ReadThroughput (Expected)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ReadThroughput"
      namespace   = "AWS/RDS"
      period      = "300"
      stat        = "Average"
      dimensions  = { DBInstanceIdentifier = each.value }
    }
    return_data = true
  }
  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_dashboard" "rds_main" {
  dashboard_name = "${var.customer_name}-RDS-Performance"
  dashboard_body = jsonencode({
    widgets = [
      for id in var.db_instance_ids : {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", id],
            [".", "FreeStorageSpace", ".", id],
            [".", "DatabaseConnections", ".", id],
            [".", "ReadIOPS", ".", id],
            [".", "WriteIOPS", ".", id]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Health Metrics for ${id}"
        }
      }
    ]
  })
}