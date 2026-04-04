resource "null_resource" "safe_rds_governance" {
  for_each = toset(var.db_instance_ids)

  triggers = {
    instance_ids = join(",", var.db_instance_ids)
  }

  provisioner "local-exec" {
    command = <<EOT
      aws rds modify-db-instance \
      --db-instance-identifier ${each.value} \
      --backup-retention-period ${var.environment == "Prod" ? 35 : 7} \
      --max-allocated-storage ${var.max_allocated_storage} \
      --deletion-protection \
      --no-apply-immediately
    EOT
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  for_each            = var.enable_alarms ? toset(var.db_instance_ids) : []
  
  alarm_name          = "${var.customer_name}-rds-cpu-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS CPU usage is high for ${each.value}"
  
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = each.value
  }
}