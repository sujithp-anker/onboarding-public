data "aws_db_instance" "selected" {
  for_each               = toset(var.db_instance_ids)
  db_instance_identifier = each.value
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each            = toset(var.db_instance_ids)
  alarm_name          = "${var.customer_name}-rds-cpu-${each.value}"
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
  threshold           = data.aws_db_instance.selected[each.value].allocated_storage * 1024 * 1024 * 1024 * 0.2
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { DBInstanceIdentifier = each.value }
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
            [".", "DatabaseConnections", ".", id]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Metrics for ${id}"
        }
      }
    ]
  })
}