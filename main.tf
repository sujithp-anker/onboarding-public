module "sns" {
  source = "./modules/sns-alerts"
  count  = var._01_enable_alerts ? 1 : 0

  customer_name = var._00_customer_name
  alert_email   = var._01_alert_email
}

module "iam_security" {
  source = "./modules/iam-security"
  
  count  = (var._02_enable_mfa_enforcement || var._02_enable_password_policy) ? 1 : 0

  customer_name          = var._00_customer_name
  enable_mfa             = var._02_enable_mfa_enforcement
  enable_password_policy = var._02_enable_password_policy
}