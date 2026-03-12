resource "aws_backup_vault" "ec2_vault" {
  name = "${var.customer_name}-ec2-backup-vault"
}

resource "aws_backup_plan" "ec2_plan" {
  name = "${var.customer_name}-ec2-backup-plan"

  rule {
    rule_name         = "Prod-7Day-Retention"
    target_vault_name = aws_backup_vault.ec2_vault.name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = 7
    }
  }

  rule {
    rule_name         = "Stage-3Day-Retention"
    target_vault_name = aws_backup_vault.ec2_vault.name
    schedule          = "cron(0 5 * * ? *)" 

    lifecycle {
      delete_after = 3
    }
  }
}

resource "aws_backup_selection" "prod_selection" {
  name         = "prod-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.ec2_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "prod-backup"
    value = "true"
  }
}

resource "aws_backup_selection" "stage_selection" {
  name         = "stage-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.ec2_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "stg-backup"
    value = "true"
  }
}

resource "aws_iam_role" "backup_role" {
  name = "${var.customer_name}-AWSBackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}