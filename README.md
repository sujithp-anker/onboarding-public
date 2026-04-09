# 🚀 AWS Customer Onboarding & Offboarding Automation

This project implements a **non-destructive** governance layer over existing AWS accounts. It adopts monitoring for resources (EC2, RDS, VPC, Load Balancers) without managing their lifecycle. Running `terraform destroy` will only remove the monitoring and logging configurations, leaving the core infrastructure untouched.

---

## 🛠️ Deployment Logic

### The `EnableMonitoring` Switch
This is a master toggle for **alert notifications**.
* **`true`**: CloudWatch Alarms are active and linked to the `AlertEmails` via SNS.
* **`false`**: All Alarms, Dashboards, and Config Rules remain active in the AWS Console for manual oversight, but **email subscriptions and alert actions are removed**. No notifications will be sent.

---

## 📋 Configuration Guide

### Core Settings
| Variable | Requirement | Description |
| :--- | :--- | :--- |
| `CustomerName` | `string` | Prefix used for naming all new resources (e.g., "AcmeCorp"). |
| `CustomerAccountId` | `string` | The 12-digit AWS Account ID. |
| `Region` | `string` | The target AWS Region (default: `us-east-1`). |
| `Environment` | `string` | `Prod` (30-day logs/backups) or `Stage` (7-day logs/backups). |
| `EnableMonitoring` | `bool` | Master toggle to enable/disable email notifications. |
| `AlertEmails` | `string` | Comma-separated list (e.g., `"admin@co.com,devops@co.com"`). |

### Feature Toggles & Inputs
| Feature | Variable / Toggle | Input Format |
| :--- | :--- | :--- |
| **IAM Security** | `EnablePasswordRotation` | `true` (90-day rotation) |
| **Access Analysis** | `EnableIAMAccessAnalyzer` | `true` (Scans shared resources) |
| **SSL Expiry** | `EnableSSLExpiryAlerts` | `true` (Alerts 30 days before expiry) |
| **AWS Health** | `EnableHealthDashboard` | `true` (Monitors service outages) |
| **Public Ports** | `EnablePublicPortsAlerts` | `true` (Alerts on non-80/443 public ports) |
| **CloudTrail** | `EnableCloudTrailLogs` | `true` (Global 90-day action log) |
| **EC2 Backups** | `ENABLE_EC2Backup` | `true` (Backs up instances with 'backup' tag) |
| **EBS Encryption** | `ENABLE_EBS_Default_Encryption` | `true` (Encrypts all FUTURE drives) |
| **EC2 Alarms** | `Instance_IDs_to_Monitor` | `"i-0abcd123, i-0efgh456"` |
| **ELB Logging** | `ENABLE_ELB_Logging_Infra` | `true` (Creates S3 storage for ELB logs) |
| **ELB Alarms** | `LB_Names_to_Monitor` | `"app-lb, web-lb"` |
| **App Health** | `TG_Names_to_Monitor` | `"app-tg, api-tg"` (Monitors unhealthy targets) |
| **DB Alarms** | `RDS_Instance_IDs` | `"db-prod, db-stage"` (CPU/Mem/Disk/Latency) |
| **Network Logs** | `Enable_VPC_FlowLogs` | `true` (Records VPC traffic) |
| **VPC Selection** | `VPCNames` | `"Main-VPC, Security-VPC"` |
| **Auto-Tagging** | `EnableResourceTagging` | `true` (Deploys 'CreatedBy' tagging stack) |
| **Budget Limit** | `SET_BudgetLimit` | Monthly USD Value (e.g., `"500"`) |
| **Budget Alarms** | `SET_BudgetActualThresholds` | `"50, 75, 100"` (Percentage of budget) |
| **Budget Forecast** | `ENABLE_BudgetForecast100` | `true` (Alerts on predicted overages) |

---

## 🛡️ Key Governance Features

* **Network Audit**: Captures VPC Flow Logs and ELB traffic logs for security forensics.
* **Proactive Security**: Monitors for unauthorized public ports and expiring SSL certificates using AWS Config.
* **Performance Intelligence**: RDS monitoring includes anomaly detection for throughput and automated storage threshold calculations.
* **Cost Management**: Tracks actual spend against limits and provides predictive forecasting alerts.
* **Auto-Tagging**: A Lambda-based solution that automatically adds `CreatedBy` and `CreatedAt` tags to supported resources upon creation.

---

### 🗄️ RDS Governance (Non-Destructive)
The stack uses the AWS CLI to "patch" existing databases with enterprise standards.
* **Storage Autoscaling**: Automatically enabled up to the `max_allocated_storage` limit.
* **Deletion Protection**: Enabled to prevent accidental database removal.
* **Backup Retention**: Set to 35 days (Prod) or 7 days (Stage).
* **Zero Downtime**: All changes use the `--no-apply-immediately` flag. Modifications will only be applied during the RDS instance's next scheduled **Maintenance Window**.

---

## ⚠️ Important Notes

* **Tagging Dependency**: VPCs and Load Balancers must have a `Name` tag in the AWS Console to be discovered by this stack.
* **EBS Encryption**: Enabling default encryption is a regional setting; it does not retroactively encrypt existing volumes.
* **RDS Backups**: Configuration changes to RDS (like enabling backups) use the `no-apply-immediately` flag and occur during the next maintenance window.
* **AWS Config**: This service must be active in your region for SSL and Public Port alerts to function.