resource "aws_db_parameter_group" "custom" {
  name   = "${var.customer_name}-custom-pg"
  family = var.db_family
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "1"
  }
}

resource "null_resource" "modify_rds_settings" {
  for_each = toset(var.db_instance_ids)

  provisioner "local-exec" {
    command = <<EOT
      aws rds modify-db-instance \
      --db-instance-identifier ${each.value} \
      --backup-retention-period ${var.environment == "Prod" ? 35 : 7} \
      --multi-az \
      --db-parameter-group-name ${aws_db_parameter_group.custom.name} \
      --cloudwatch-logs-export-configuration '{"EnableLogTypes":["slowquery","error"]}' \
      --apply-immediately
    EOT
  }
}