data "aws_vpc" "selected" {
  for_each = toset(var.vpc_names)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

resource "aws_cloudwatch_log_group" "flow_log" {
  for_each = toset(var.vpc_names)
  name              = "/aws/vpc/flow-logs/${var.customer_name}-${each.value}"
  retention_in_days = var.environment == "Prod" ? 30 : 7
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.customer_name}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = [for lg in aws_cloudwatch_log_group.flow_log : "${lg.arn}:*"]
    }]
  })
}

resource "aws_flow_log" "main" {
  for_each = toset(var.vpc_names)
  
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log[each.value].arn
  traffic_type    = "ALL"
  vpc_id          = data.aws_vpc.selected[each.value].id

  tags = {
    Name        = "${var.customer_name}-${each.value}-flow-logs"
    Environment = var.environment
    ManagedBy   = "Gaia-Onboarding"
  }
}