resource "null_resource" "safe_rds_governance" {
  for_each = toset(var.db_instance_ids)

  triggers = {
    instance_ids          = join(",", var.db_instance_ids)
    backup_days           = var.environment == "Prod" ? 35 : 7
  }

  provisioner "local-exec" {
    command = <<EOT
      aws rds modify-db-instance \
        --db-instance-identifier ${each.value} \
        --backup-retention-period ${var.environment == "Prod" ? 35 : 7} \
        --no-apply-immediately \
        --region ${var.region}
    EOT
  }
}