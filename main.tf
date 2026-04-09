module "alerts" {
  source        = "./modules/sns-alerts"
  
  customer_name = var.CustomerName
  alert_email   = var.EnableMonitoring ? var.AlertEmails : ""
}

module "iam_governance" {
  source                     = "./modules/iam-security"
  
  customer_name              = var.CustomerName
  enable_password_rotation   = var.EnablePasswordRotation
  enable_iam_access_analyzer = var.EnableIAMAccessAnalyzer
}

module "monitoring" {
  source                   = "./modules/security-governance"
  
  customer_name            = var.CustomerName
  enable_ssl_expiry_alerts = var.EnableSSLExpiryAlerts
  enable_health_dashboard  = var.EnableHealthDashboard
  sns_topic_arn            = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
}

module "cloudtrail" {
  source        = "./modules/cloudtrail"
  
  count         = var.EnableCloudTrailLogs ? 1 : 0
  customer_name = var.CustomerName
  account_id    = var.CustomerAccountId
}

module "vpc_governance" {
  source        = "./modules/vpc-governance"
  
  count         = var.Enable_VPC_FlowLogs ? 1 : 0
  customer_name = var.CustomerName
  environment   = var.Environment
  vpc_names     = compact(split(",", replace(var.VPCNames, " ", "")))
}

module "ec2_backup" {
  source        = "./modules/ec2-backup"
  
  count         = var.EnableEC2Backup ? 1 : 0
  customer_name = var.CustomerName
  environment   = var.Environment
}

module "ec2_monitoring" {
  source        = "./modules/ec2-governance"
  
  count         = var.Instance_IDs_to_Monitor != "" ? 1 : 0
  customer_name         = var.CustomerName
  instance_ids          = compact(split(",", replace(var.Instance_IDs_to_Monitor, " ", "")))
  sns_topic_arn         = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
  enable_ebs_encryption = var.ENABLE_EBS_Default_Encryption
}

module "governance" {
  source                     = "./modules/publicport-alerts"
  providers = {
    aws = aws.onboarding 
  }
  
  customer_name              = var.CustomerName
  enable_public_ports_alerts = var.EnablePublicPortsAlerts 
  sns_topic_arn              = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
  region = var.Region
}

module "load_balancer_infra" {
  source        = "./modules/load-balancer-infra"
  
  count         = var.ENABLE_ELB_Logging_Infra ? 1 : 0
  customer_name = var.CustomerName
  account_id    = var.CustomerAccountId
  region        = var.Region
  environment   = var.Environment
  lb_names      = compact(split(",", replace(var.LB_Names_to_Monitor, " ", "")))
}

module "load_balancer_monitoring" {
  source        = "./modules/load-balancer-monitoring"
  
  count         = var.LB_Names_to_Monitor != "" ? 1 : 0

  customer_name = var.CustomerName
  lb_names      = compact(split(",", replace(var.LB_Names_to_Monitor, " ", "")))
  tg_names      = compact(split(",", replace(var.TG_Names_to_Monitor, " ", "")))
  sns_topic_arn = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
}

module "rds_monitoring" {
  source        = "./modules/rds-monitoring"
  
  count         = var.RDS_Instance_IDs != "" ? 1 : 0

  customer_name   = var.CustomerName
  region          = var.Region
  environment     = var.Environment
  sns_topic_arn   = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
  db_instance_ids = compact(split(",", replace(var.RDS_Instance_IDs, " ", "")))
}

module "rds_governance" {
  source = "./modules/rds-governance"
  
  count         = var.RDS_Instance_IDs != "" ? 1 : 0

  environment = var.Environment
  region = var.Region
  db_instance_ids = compact(split(",", replace(var.RDS_Instance_IDs, " ", "")))
}

module "budget_alerts" {
  source                = "./modules/budget-alerts"
  
  count                 = var.SET_BudgetLimit != "" ? 1 : 0

  customer_name         = var.CustomerName
  budget_limit          = var.SET_BudgetLimit
  actual_thresholds     = var.SET_BudgetActualThresholds
  enable_forecasted_100 = var.ENABLE_BudgetForecast100
  sns_topic_arn         = var.EnableMonitoring ? module.alerts.sns_topic_arn : ""
}

module "resource_tagging" {
  source                             = "./modules/resource-tagging-cft"
  
  customer_name                      = var.CustomerName  
  enable_resource_tagging_automation = var.EnableResourceTagging
}