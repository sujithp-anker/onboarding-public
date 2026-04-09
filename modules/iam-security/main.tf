terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_account_password_policy" "strict" {
  count = var.enable_password_rotation ? 1 : 0

  max_password_age               = 90
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
}

resource "aws_accessanalyzer_analyzer" "main" {
  count = var.enable_iam_access_analyzer ? 1 : 0

  analyzer_name = "${var.customer_name}-access-analyzer"
  type          = "ACCOUNT"
}