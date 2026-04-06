module "sns" {
  source = "./modules/sns-alerts"
  count  = (var.ENABLE_SNSAlert && var.EnableMonitoring) ? 1 : 0

  customer_name = var.CustomerName
  alert_email   = var.AlertEmail
}

module "iam_security" {
  source = "./modules/iam-security"
  count  = var.ENABLE_IAM_Governance ? 1 : 0

  customer_name     = var.CustomerName
  enable_monitoring = var.EnableMonitoring
}

module "security_governance" {
  source = "./modules/security-governance"
  count  = (var.ENABLE_SecurityAuditing && var.EnableMonitoring) ? 1 : 0

  customer_name = var.CustomerName
  sns_topic_arn = module.sns[0].sns_topic_arn
}

module "s3_governance" {
  source = "./modules/s3-governance"
  count  = var.ENABLE_S3_Governance != "" ? 1 : 0

  customer_name   = var.CustomerName
  environment     = var.EnvironmentTag
  s3_bucket_names = split(",", replace(var.ENABLE_S3_Governance, " ", ""))
}

module "cloudtrail" {
  source = "./modules/cloudtrail"
  count  = var.ENABLE_CloudTrailLogs ? 1 : 0

  customer_name = var.CustomerName
  account_id    = var.CustomerAccountId
}

module "vpc_governance" {
  source = "./modules/vpc-governance"
  count  = var.Enable_VPC_FlowLogs ? 1 : 0

  customer_name = var.CustomerName
  environment   = var.EnvironmentTag
  vpc_names     = split(",", replace(var.VPCNames, " ", ""))
}

module "ec2_backup" {
  source = "./modules/ec2-backup"
  count  = var.ENABLE_EC2Backup ? 1 : 0

  customer_name = var.CustomerName
  environment   = var.EnvironmentTag
}

module "ec2_monitoring" {
  source = "./modules/ec2-governance"
  count  = (var.Instance_IDs_to_Monitor != "" && var.EnableMonitoring) ? 1 : 0

  customer_name = var.CustomerName
  instance_ids  = split(",", replace(var.Instance_IDs_to_Monitor, " ", ""))
  sns_topic_arn = module.sns[0].sns_topic_arn
  
  enable_ebs_encryption = var.ENABLE_EBS_Default_Encryption
}

module "load_balancer_infra" {
  source = "./modules/load-balancer-infra"
  count  = var.ENABLE_ELB_Logging_Infra ? 1 : 0

  customer_name = var.CustomerName
  account_id    = var.CustomerAccountId
  region        = var.Region
  environment   = var.EnvironmentTag
  lb_names      = split(",", replace(var.LB_Names_to_Monitor, " ", ""))
}

module "load_balancer_monitoring" {
  source = "./modules/load-balancer-monitoring"
  count  = (var.LB_Names_to_Monitor != "" && var.EnableMonitoring) ? 1 : 0

  customer_name = var.CustomerName
  lb_names      = split(",", replace(var.LB_Names_to_Monitor, " ", ""))
  tg_names      = split(",", replace(var.TG_Names_to_Monitor, " ", ""))
  sns_topic_arn = module.sns[0].sns_topic_arn
}

module "rds_governance" {
  source = "./modules/rds-governance"
  count  = var.RDS_Instance_IDs != "" ? 1 : 0

  customer_name   = var.CustomerName
  environment     = var.EnvironmentTag
  db_instance_ids = split(",", replace(var.RDS_Instance_IDs, " ", ""))
  
  enable_alarms   = var.EnableMonitoring
  sns_topic_arn   = var.EnableMonitoring ? module.sns[0].sns_topic_arn : ""
}

module "budget_alerts" {
  source = "./modules/budget-alerts"
  count  = (var.SET_BudgetLimit != "" && var.EnableMonitoring) ? 1 : 0

  customer_name         = var.CustomerName
  budget_limit          = var.SET_BudgetLimit
  actual_thresholds     = var.SET_BudgetActualThresholds
  enable_forecasted_100 = var.ENABLE_BudgetForecast100
  sns_topic_arn         = module.sns[0].sns_topic_arn
}