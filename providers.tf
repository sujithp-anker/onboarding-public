provider "aws" {
  region = var.Region

  dynamic "assume_role" {
    for_each = var.CrossAccountAssumeRoleARN != "" ? [1] : []
    content {
      role_arn     = var.CrossAccountAssumeRoleARN
      session_name = "OnboardingSession"
    }
  }
}