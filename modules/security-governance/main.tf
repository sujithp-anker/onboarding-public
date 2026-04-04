resource "aws_config_config_rule" "public_port_check" {
  name        = "${var.customer_name}-authorized-public-ports-only"
  description = "Checks whether SGs allow unrestricted incoming traffic only to authorized ports (80/443)."

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }

  input_parameters = jsonencode({
    authorizedTcpPorts = "80,443"
  })
}

resource "aws_config_config_rule" "acm_expiration_check" {
  name        = "${var.customer_name}-acm-expiration-check"
  description = "Checks whether ACM certificates are marked for expiration within 30 days."

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  input_parameters = jsonencode({
    daysToExpiration = var.acm_days_to_expiration
  })
}

resource "aws_cloudwatch_event_rule" "aws_health_alerts" {
  name        = "${var.customer_name}-aws-health-alerts"
  description = "Triggers on AWS Health events (Service issues, scheduled maintenance)"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })
}

resource "aws_cloudwatch_event_target" "health_sns" {
  rule      = aws_cloudwatch_event_rule.aws_health_alerts.name
  target_id = "SendHealthToSNS"
  arn       = var.sns_topic_arn
}

resource "aws_cloudwatch_event_rule" "config_violations" {
  name        = "${var.customer_name}-security-violation-alert"
  description = "Triggers when Config Rules (SG or ACM) find a NON_COMPLIANT resource"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail-type = ["Config Rules Compliance Change"]
    detail = {
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "config_sns" {
  rule      = aws_cloudwatch_event_rule.config_violations.name
  target_id = "SendConfigAlertToSNS"
  arn       = var.sns_topic_arn
}