provider "aws" {
  region = "us-east-1"

#   assume_role {
#     role_arn     = "arn:aws:iam::${var.customer_account_id}:role/OrganizationAccountAccessRole"
#     session_name = "OnboardingSession"
#   }
}