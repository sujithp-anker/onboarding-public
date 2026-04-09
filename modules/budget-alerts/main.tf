terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_budgets_budget" "monthly_cost_budget" {
  name              = "${var.customer_name}-monthly-cost-budget"
  budget_type       = "COST"
  limit_amount      = var.budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  
  time_period_start = formatdate("YYYY-MM-DD_hh:mm", timestamp())

  dynamic "notification" {
    for_each = (var.actual_thresholds != "" && var.sns_topic_arn != "") ? split(",", var.actual_thresholds) : []
    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = trimspace(notification.value)
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_sns_topic_arns = [var.sns_topic_arn]
    }
  }

  dynamic "notification" {
    for_each = (var.enable_forecasted_100 && var.sns_topic_arn != "") ? [1] : []
    content {
      comparison_operator       = "GREATER_THAN"
      threshold                 = 100
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_sns_topic_arns = [var.sns_topic_arn]
    }
  }

  cost_types {
    include_credit             = true     
    include_discount           = true 
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
  }

  lifecycle {
    ignore_changes = [time_period_start]
  }
}