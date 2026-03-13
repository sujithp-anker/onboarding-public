data "aws_lb" "selected" {
  name = var.lb_name
}

data "aws_lb_target_group" "selected" {
  name = var.tg_name
}

resource "aws_cloudwatch_metric_alarm" "high_5xx" {
  alarm_name          = "${var.customer_name}-5xx-threshold-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    LoadBalancer = data.aws_lb.selected.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.customer_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    TargetGroup  = data.aws_lb_target_group.selected.arn_suffix
    LoadBalancer = data.aws_lb.selected.arn_suffix
  }
}