terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_lb_target_group" "selected" {
  for_each = toset(var.tg_names)
  name     = each.value
}

data "aws_lb" "selected" {
  for_each = toset(var.lb_names)
  name     = each.value
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  for_each            = toset(var.tg_names)
  
  alarm_name          = "${var.customer_name}-unhealthy-hosts-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    TargetGroup = data.aws_lb_target_group.selected[each.value].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  for_each            = toset(var.lb_names)
  
  alarm_name          = "${var.customer_name}-alb-5xx-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    LoadBalancer = data.aws_lb.selected[each.value].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_4xx" {
  for_each            = toset(var.tg_names)
  
  alarm_name          = "${var.customer_name}-4xx-alarm-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    TargetGroup = data.aws_lb_target_group.selected[each.value].arn_suffix
  }
}