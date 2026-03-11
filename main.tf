module "sns" {
  source = "./modules/sns-alerts"
  count  = var.EnableAlerts ? 1 : 0

  customer_name = var.CustomerName
  alert_email   = var.AlertEmail
}

module "iam_security" {
  source = "./modules/iam-security"
  
  count  = (var.EnableMFAEnforcement || var.EnablePasswordPolicy) ? 1 : 0

  customer_name          = var.CustomerName
  enable_mfa             = var.EnableMFAEnforcement
  enable_password_policy = var.EnablePasswordPolicy
}