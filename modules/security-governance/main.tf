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

resource "aws_cloudwatch_event_rule" "sg_violation" {
  name        = "security-group-unauthorized-port-alert"
  description = "Triggers when a Security Group opens unauthorized ports to the public"

  event_pattern = jsonencode({
    source      = ["aws.config"],
    detail-type = ["Config Rules Compliance Change"],
    detail = {
      configRuleName = [aws_config_config_rule.public_port_check.name],
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_alert" {
  rule      = aws_cloudwatch_event_rule.sg_violation.name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn
}

resource "aws_config_config_rule" "acm_expiration_check" {
  name        = "${var.customer_name}-acm-expiration-check"
  description = "Checks whether ACM certificates are marked for expiration within the specified number of days."

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  input_parameters = jsonencode({
    daysToExpiration = var.acm_days_to_expiration
  })
}

resource "aws_cloudwatch_event_rule" "acm_violation" {
  name        = "acm-certificate-expiration-alert"
  description = "Triggers when an ACM certificate is nearing expiration"

  event_pattern = jsonencode({
    source      = ["aws.config"],
    detail-type = ["Config Rules Compliance Change"],
    detail = {
      configRuleName = [aws_config_config_rule.acm_expiration_check.name],
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "acm_sns_alert" {
  rule      = aws_cloudwatch_event_rule.acm_violation.name
  target_id = "SendACMAlertToSNS"
  arn       = var.sns_topic_arn
}