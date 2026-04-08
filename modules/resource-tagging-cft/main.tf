resource "aws_cloudformation_stack" "resource_tagging" {
  count = var.enable_resource_tagging_automation ? 1 : 0

  name          = "${var.customer_name}-resource-tagging-stack"
  capabilities  = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  
  template_body = file("${path.module}/resource_tagging.yaml")

  parameters = {
    LambdaAutoTaggingFunctionName = "${var.customer_name}-tagging-function"
    EventBridgeRuleName           = "${var.customer_name}-tagging-rule"
    IAMAutoTaggingRoleName         = "${var.customer_name}-tagging-role"
    TrailName                      = "${var.customer_name}-tagging-trail"
  }
}