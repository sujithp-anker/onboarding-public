provider "aws" {
  region = "us-east-1"

  dynamic "assume_role" {
    for_each = var.CrossAccountAssumeRoleARN != "" ? [1] : []
    content {
      role_arn     = var.CrossAccountAssumeRoleARN
      session_name = "OnboardingSession"
    }
  }
}