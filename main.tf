module "sns" {
  source = "./modules/sns-alerts"
  
  count  = var.enable_phase_1_alerts ? 1 : 0

  customer_name = var.customer_name
  alert_email   = var.alert_email
}
