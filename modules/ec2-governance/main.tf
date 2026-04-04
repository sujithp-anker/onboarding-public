resource "aws_ebs_encryption_by_default" "enabled" {
  enabled = var.enable_ebs_encryption
}

resource "aws_cloudwatch_metric_alarm" "status_check_fail" {
  for_each            = toset(var.instance_ids)
  
  alarm_name          = "${var.customer_name}-status-check-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "Status check failed for instance: ${each.value}"
  
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  ok_actions          = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    InstanceId = each.value
  }
}

resource "aws_ec2_tag" "standard_naming" {
  for_each    = toset(var.instance_ids)
  resource_id = each.value
  key         = "ManagedBy"
  value       = "Gaia-Onboarding"
}

resource "aws_ec2_tag" "customer_tag" {
  for_each    = toset(var.instance_ids)
  resource_id = each.value
  key         = "Owner"
  value       = var.customer_name
}