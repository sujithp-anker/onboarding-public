variable "CustomerName" {
  type        = string
  description = "The name of the client (e.g., 'AcmeCorp'). Used to name all new resources."
}

variable "CustomerAccountId" {
  type        = string
  description = "The 12-digit AWS Account ID (e.g., 123456789012)."
}

variable "Region" { 
  type        = string
  default     = "us-east-1"
  description = "The AWS Region where the servers and databases are located."
}

variable "EnvironmentTag" {
  type        = string
  default     = "Stage"
  description = "Set to 'Prod' for 30-day backups/logs, or 'Stage' for 7-day backups/logs."
}

variable "EnableMonitoring" {
  type        = bool
  default     = true
  description = "Turn OFF (false) to stop alerts and emails."
}

variable "ENABLE_SNSAlert" {
  type        = bool
  default     = false
  description = "Enable this to create a central alert system."
}

variable "AlertEmail" {
  type        = string
  default     = ""
  description = "The email address where all alerts will be sent."
}

variable "ENABLE_IAM_Governance" {
  type        = bool
  default     = false
  description = "Enable to enforce 90-day passwords and scan for shared resources."
}

variable "ENABLE_S3_Governance" {
  type        = string
  default     = ""
  description = "List of bucket names (comma-separated) to secure and encrypt."
}

variable "ENABLE_SecurityAuditing" {
  type        = bool
  default     = false
  description = "Enable to monitor SSL certificate expiry and AWS service outages."
}

variable "ENABLE_PublicPortAlerts" {
  type        = bool
  default     = false
  description = "Alert if any server ports (other than 80/443) are opened to the public."
}

variable "ENABLE_CloudTrailLogs" {
  type        = bool
  default     = false
  description = "Enable to keep a 90-day record of every action taken in the AWS account."
}

variable "ENABLE_EC2Backup" {
  type        = bool
  default     = false
  description = "Enable automated backups for servers with the 'backup' tag."
}

variable "ENABLE_EBS_Default_Encryption" {
  type        = bool
  default     = false
  description = "Enable to ensure all FUTURE hard drives created are encrypted."
}

variable "Instance_IDs_to_Monitor" {
  type        = string
  default     = ""
  description = "List of Instance IDs (comma-separated) to alert if the server goes down."
}

variable "ENABLE_ELB_Logging_Infra" {
  type        = bool
  default     = false
  description = "Enable to create storage for Load Balancer traffic logs."
}

variable "LB_Names_to_Monitor" {
  type        = string
  default     = ""
  description = "List of Load Balancer names (comma-separated) to monitor for errors."
}

variable "TG_Names_to_Monitor" {
  type        = string
  default     = ""
  description = "List of Target Group names (comma-separated) to check for unhealthy apps."
}

variable "RDS_Instance_IDs" {
  type        = string
  default     = ""
  description = "List of Database IDs (comma-separated) for performance alerts and backups."
}

variable "DB_Family" {
  type        = string
  default     = "mysql8.0"
  description = "The database type (e.g., mysql8.0 or postgres14)."
}

variable "Enable_VPC_FlowLogs" {
  type        = bool
  default     = false
  description = "Enable to record network traffic for security audits."
}

variable "VPCNames" {
  type        = string
  default     = ""
  description = "List of VPC Name tags (comma-separated) to enable traffic logging."
}

variable "SET_BudgetLimit" {
  type        = string
  default     = ""
  description = "Monthly spending limit in USD (e.g., 500)."
}

variable "SET_BudgetActualThresholds" {
  type        = string
  default     = "50,75,100"
  description = "Alert when spending reaches these percentages (e.g., 50, 75, 100)."
}

variable "ENABLE_BudgetForecast100" {
  type        = bool
  default     = false
  description = "Alert if AWS predicts you will go over budget by the end of the month."
}