output "backup_plan_id" {
  value = aws_backup_plan.ec2_plan.id
}

output "backup_role_arn" {
  value = aws_iam_role.backup_role.arn
}