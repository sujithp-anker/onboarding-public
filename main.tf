module "sns" {
  source = "./modules/sns-alerts"
  count  = var.ENABLE_SNS_alerts ? 1 : 0

  customer_name = var.CustomerName
  alert_email   = var.AlertEmail
}

module "iam_security" {
  source = "./modules/iam-security"
  
  count  = (var.ENABLE_MFAEnforcement || var.ENABLE_PasswordPolicy) ? 1 : 0

  customer_name          = var.CustomerName
  enable_mfa             = var.ENABLE_MFAEnforcement
  enable_password_policy = var.ENABLE_PasswordPolicy
}