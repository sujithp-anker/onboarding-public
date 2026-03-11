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

module "budget_alerts" {
  source = "./modules/budget-alerts"
  
  count = (var.ENABLE_BudgetThreshold_Actual_50 || var.ENABLE_BudgetThreshold_Actual_75 || var.ENABLE_BudgetThreshold_Actual_100 || var.ENABLE_BudgetThreshold_Forecast_100) ? 1 : 0

  customer_name         = var.CustomerName
  budget_limit          = var.SET_BudgetLimit
  sns_topic_arn         = module.sns[0].sns_topic_arn
  
  enable_actual_50      = var.ENABLE_BudgetThreshold_Actual_50
  enable_actual_75      = var.ENABLE_BudgetThreshold_Actual_75
  enable_actual_100     = var.ENABLE_BudgetThreshold_Actual_100
  enable_forecasted_100 = var.ENABLE_BudgetThreshold_Forecast_100
}