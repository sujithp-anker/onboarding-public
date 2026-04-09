# 🚀 AWS Governance & Monitoring Stack

This project implements a **non-destructive** governance layer over existing AWS accounts. It adopts monitoring for resources (EC2, RDS, S3, VPC) without managing their lifecycle. Running `terraform destroy` will only remove the monitoring and logging configurations, leaving the core infrastructure untouched.

---

## 🛠️ Deployment Logic

### The `EnableMonitoring` Switch
This is a master toggle for **alert notifications**.
* **`true`**: CloudWatch Alarms are created and linked to the `AlertEmails` via SNS.
* **`false`**: All Alarms and Dashboards remain active in the AWS Console for manual oversight, but **email subscriptions and alert actions are removed**. No notifications will be sent.

---

## 📋 Configuration Guide

| Variable | Requirement | Description |
| :--- | :--- | :--- |
| `EnableMonitoring` | `bool` | Master toggle to enable/disable email notifications. |
| `AlertEmails` | `string` | Comma-separated list (e.g., `"admin@co.com,devops@co.com"`). |
| `CustomerName` | `string` | Used as a prefix for all created resources. |
| `Environment` | `string` | `Prod` (30-day logs) or `Stage` (7-day logs). |
| `Instance_IDs_to_Monitor` | `string` | Comma-separated list of EC2 instance IDs. |
| `RDS_Instance_IDs` | `string` | Comma-separated list of RDS DB identifiers. |
| `VPCNames` | `string` | Comma-separated list of VPC `Name` tags. |

---

## 🛡️ Key Features

* **Security**: Enforces a 90-day IAM password rotation policy and enables IAM Access Analyzer.
* **Audit**: Deploys a Multi-Region CloudTrail and VPC Flow Logs for traffic forensics.
* **Guardrails**: Alerts on public ports (22/3389) and ACM certificates expiring within 30 days.
* **RDS Monitoring**: Alarms for CPU > 80%, Storage < 20% free, and Read/Write latency.
* **Auto-Tagging**: Deploys a Lambda-based solution to tag resources with `CreatedBy` and `CreatedAt`.
* **Budgets**: Sets a monthly USD cost limit with alerts at defined thresholds.

---

## ⚠️ Important Notes

* **Resource Discovery**: VPCs and Load Balancers are identified by their **Name Tag**. Ensure these tags are present in AWS before deploying.
* **EBS Encryption**: The `ENABLE_EBS_Default_Encryption` setting is regional and only applies to **newly created** volumes.
* **AWS Config**: Ensure AWS Config is enabled in the target region; otherwise, SSL and Public Port rules will remain in a "Pending" state.
* **RDS Changes**: Backups and Deletion Protection settings use the `no-apply-immediately` flag and will trigger during the next maintenance window.