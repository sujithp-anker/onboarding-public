terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_config_config_rule" "public_port_check" {
  count       = var.enable_public_ports_alerts ? 1 : 0
  name        = "${var.customer_name}-public-port-check"
  description = "Checks for Security Groups with unrestricted (0.0.0.0/0) access to non-web ports."

  source {
    owner             = "AWS"
    source_identifier = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  }

  input_parameters = jsonencode({
    authorizedTcpPorts = "80,443"
  })
}

resource "aws_cloudwatch_event_rule" "public_port_violation" {
  count       = var.enable_public_ports_alerts ? 1 : 0
  name        = "${var.customer_name}-public-port-violation"
  description = "Triggers when a Security Group is found with unauthorized public ports"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail-type = ["Config Rules Compliance Change"]
    detail = {
      configRuleName = ["${var.customer_name}-public-port-check"]
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_public_port" {
  count     = var.enable_public_ports_alerts ? 1 : 0
  rule      = aws_cloudwatch_event_rule.public_port_violation[0].name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn
}