resource "aws_sns_topic" "alerts" {
  count = var.alert_email != "" ? 1 : 0
  name  = "${var.customer_name}-alerts"
}

resource "aws_sns_topic_subscription" "email_targets" {
  for_each = var.alert_email != "" ? toset(split(",", var.alert_email)) : []
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = trimspace(each.value)
}