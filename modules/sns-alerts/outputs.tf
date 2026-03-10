output "sns_topic_arn" {
  value       = aws_sns_topic.customer_alerts.arn
  description = "The ARN of the SNS topic created"
}