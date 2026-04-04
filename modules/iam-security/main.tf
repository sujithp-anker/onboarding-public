resource "aws_iam_group" "mfa_group" {
  count = var.enable_mfa ? 1 : 0
  name  = "${var.customer_name}-mfa-enforcement-group"
}

resource "aws_iam_policy" "mfa_policy" {
  count       = var.enable_mfa ? 1 : 0
  name        = "${var.customer_name}-EnforceMFA"
  description = "Allows users to change their own passwords and manage MFA."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo",
        Effect = "Allow",
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnMFA",
        Effect = "Allow",
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ],
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "mfa_attach" {
  count      = var.enable_mfa ? 1 : 0
  group      = aws_iam_group.mfa_group[0].name
  policy_arn = aws_iam_policy.mfa_policy[0].arn
}

resource "aws_iam_account_password_policy" "strict" {
  count                          = var.enable_password_policy ? 1 : 0
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 3
}

resource "aws_accessanalyzer_analyzer" "governance" {
  count         = var.enable_monitoring ? 1 : 0
  analyzer_name = "${var.customer_name}-access-analyzer"
  type          = "ACCOUNT"

  tags = {
    Name = "${var.customer_name}-access-analyzer"
  }
}