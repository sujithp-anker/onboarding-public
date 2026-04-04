resource "aws_sns_topic" "customer_alerts" {
  name = "${var.customer_name}-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.customer_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}