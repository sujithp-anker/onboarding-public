# 🚀 AWS Governance & Onboarding Stack

This Terraform project provides a **non-destructive** way to onboard existing AWS accounts into a managed governance and monitoring framework. It is designed to "adopt" existing resources (EC2, RDS, S3, VPC) without taking ownership of their lifecycle, ensuring that a `terraform destroy` will only remove monitoring and logs, not the client's infrastructure.

---

## 🛠️ Onboarding Prerequisites

To ensure the stack deploys successfully, follow these dependency rules:

### 1. The "Notification Heartbeat"
* **Requirement**: If you want **any** alerts (EC2, RDS, Budget, or Security), you **MUST**:
    * Set `ENABLE_SNSAlert = true`
    * Provide a valid `AlertEmail`
    * Set `EnableMonitoring = true`
* **Why?**: All monitoring modules look for the SNS Topic ARN. If SNS is disabled, the modules will skip creating the actual CloudWatch Alarms to prevent errors.

### 2. Resource Naming (The "Name" Tag)
* **Requirement**: For **VPC Flow Logs** and **Load Balancer** modules, ensure the existing resources in AWS have a `Name` tag.
* **Why?**: The stack uses `Data Filters` to find resources by their Name tag. If a VPC or ALB exists but isn't named, Terraform will return a "Resource Not Found" error.

### 3. Environment Scaling
* **Requirement**: Choose either `Prod` or `Stage` for the `EnvironmentTag`.
* **Impact**: 
    * **Prod**: 30-35 day log retention / 7-day backup retention.
    * **Stage**: 7-day log retention / 3-day backup retention.

---

## ⚙️ Configuration Guide

| Feature | Variable to Enable | Required Input |
| :--- | :--- | :--- |
| **Budgeting** | `SET_BudgetLimit` | Enter a USD value (e.g., "500"). |
| **Server Alarms** | `Instance_IDs_to_Monitor` | Comma-separated list of IDs. |
| **DB Governance** | `RDS_Instance_IDs` | Comma-separated list of DB Identifiers. |
| **S3 Security** | `ENABLE_S3_Governance` | Comma-separated list of Bucket Names. |
| **Traffic Logs** | `VPCNames` | Comma-separated list of VPC Name Tags. |

---

## 🛑 The Offboarding Toggle (`EnableMonitoring`)

This stack includes a unique safety switch for offboarding clients or pausing alerts without deleting historical data.

* **When `EnableMonitoring = true`**: All CloudWatch Alarms, SNS Topics, and Budget Notifications are active.
* **When `EnableMonitoring = false`**: 
    * **Deleted**: All Alarms, SNS Topics, and Subscriptions. (Stops all emails and costs associated with monitoring).
    * **Retained**: S3 Buckets, CloudTrail Logs, VPC Flow Logs, and IAM Policies. (Ensures audit history is preserved for compliance).

---

## ⚠️ Safety Warnings

1. **RDS Modifications**: This stack uses the `--no-apply-immediately` flag for RDS governance (Backups, Deletion Protection). Changes will take effect during the next **Maintenance Window** to avoid downtime.
2. **EBS Encryption**: Enabling `ENABLE_EBS_Default_Encryption` is a regional setting. It will not encrypt existing disks but will ensure **all future** disks created in that region are encrypted by default.
3. **AWS Config**: The Security Governance module requires **AWS Config** to be active in the account. If it is not enabled, the SSL Expiry and Public Port alerts will stay in a "Pending" state.