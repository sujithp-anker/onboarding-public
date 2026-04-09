terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "onboarding"
  region = var.Region

  dynamic "assume_role" {
    for_each = var.CrossAccountRoleArn != "" ? [1] : []
    content {
      role_arn     = var.CrossAccountRoleArn
      session_name = "GaiaOnboardingSession"
    }
  }
}