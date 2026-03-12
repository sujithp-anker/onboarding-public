module "sns" {
  source = "./modules/sns-alerts"
  count  = var.ENABLE_SNSAlert ? 1 : 0

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

module "budget_alerts" {
  source = "./modules/budget-alerts"

  count  = var.SET_BudgetLimit != "" ? 1 : 0

  customer_name         = var.CustomerName
  budget_limit          = var.SET_BudgetLimit
  
  actual_thresholds      = var.SET_BudgetActualThresholds
  enable_forecasted_100  = var.ENABLE_BudgetForecast100
  
  sns_topic_arn          = module.sns[0].sns_topic_arn
}

module "cloudtrail" {
  source = "./modules/cloudtrail"
  count  = var.ENABLE_CloudTrailLogs ? 1 : 0

  customer_name = var.CustomerName
  account_id    = var.CustomerAccountId
}