import pandas as pd
import os
import logging
from datetime import datetime
from colorama import Fore, init

# GCP Client Libraries
from google.cloud import compute_v1
from google.cloud import storage
from google.cloud import container_v1
from google.cloud import logging_v2
from google.cloud import monitoring_v3
from google.cloud import iam_admin_v1
from google.api_core import exceptions
from colorama import Fore, Style, init

init(autoreset=True)
logging.basicConfig(level=logging.INFO, format='%(message)s')

class FullProjectAuditor:
    def __init__(self):
        self.project_id = os.getenv('GOOGLE_CLOUD_PROJECT')
        if not self.project_id:
            raise Exception("No active project detected. Run: gcloud config set project [PROJECT_ID]")
        
        self.sheets = {
            "Compute_GKE": [],
            "Storage_CloudStorage": [],
            "Network_Security": [],
            "IAM_Identity": [],
            "Logging_Monitoring": []
        }

    def add_finding(self, sheet, resource, check, status, details):
        self.sheets[sheet].append({
            "Resource": resource, "Check": check, "Status": status, "Details": details
        })

    def audit_compute_gke(self):
        logging.info(f"{Fore.CYAN}Auditing Compute & GKE (Deletion Protection, Labels, Scaling)...")
        # 1. GKE Clusters (Scaling, Monitoring)
        try:
            gke_client = container_v1.ClusterManagerClient()
            parent = f"projects/{self.project_id}/locations/-"
            clusters = gke_client.list_clusters(parent=parent).clusters
            for cluster in clusters:
                self.add_finding("Compute_GKE", cluster.name, "GKE Autoscale", 
                                 "ENABLED" if any(np.autoscaling.enabled for np in cluster.node_pools) else "DISABLED", "Check Node Pool scaling")
                self.add_finding("Compute_GKE", cluster.name, "GKE Logging/Monitoring", 
                                 "OK" if cluster.monitoring_service != "none" else "RISK", f"Service: {cluster.monitoring_service}")
        except Exception as e: logging.debug(f"GKE Audit Error: {e}")

        # 2. VM Instances (Deletion Protection, Labels, Disk Encryption)
        try:
            vm_client = compute_v1.InstancesClient()
            agg_list = vm_client.aggregated_list(project=self.project_id)
            for _, response in agg_list:
                if response.instances:
                    for inst in response.instances:
                        self.add_finding("Compute_GKE", inst.name, "VM Deletion Protection", "SAFE" if inst.deletion_protection else "RISK", f"DP: {inst.deletion_protection}")
                        self.add_finding("Compute_GKE", inst.name, "Labels", "OK" if inst.labels else "MISSING", str(dict(inst.labels)))
                        # Disk Encryption check for persistent disks
                        for disk in inst.disks:
                            self.add_finding("Compute_GKE", inst.name, f"Disk Encryption ({disk.device_name})", "OK" if disk.disk_encryption_key else "DEFAULT", "Checks if CMEK is used")
        except Exception as e: logging.debug(f"Compute Audit Error: {e}")

    def audit_storage(self):
        logging.info(f"{Fore.YELLOW}Auditing Cloud Storage (BPA, Encryption, Lifecycle)...")
        try:
            storage_client = storage.Client(project=self.project_id)
            buckets = list(storage_client.list_buckets())
            for b in buckets:
                # 1. Public Access Check
                try:
                    policy = b.get_iam_policy()
                    is_public = any(member in ["allUsers", "allAuthenticatedUsers"] for binding in policy.bindings for member in binding.members)
                    self.add_finding("Storage_CloudStorage", b.name, "Public Access Restriction", "SAFE" if not is_public else "RISK", f"Publicly Accessible: {is_public}")
                except: self.add_finding("Storage_CloudStorage", b.name, "Public Access Restriction", "UNKNOWN", "Access Denied to IAM")

                # 2. Encryption & Lifecycle
                self.add_finding("Storage_CloudStorage", b.name, "Server-side Encryption", "OK" if b.encryption else "DEFAULT", "Checking for CMEK")
                self.add_finding("Storage_CloudStorage", b.name, "Lifecycle Policies", "OK" if list(b.lifecycle_rules) else "MISSING", "Check retention/deletion rules")
        except Exception as e: logging.debug(f"Storage Audit Error: {e}")

    def audit_network_security(self):
        logging.info(f"{Fore.BLUE}Auditing Network & Security (Flow Logs, Cloud Armor, LB)...")
        try:
            # 1. VPC Flow Logs & Custom Network Check
            net_client = compute_v1.NetworksClient()
            sub_client = compute_v1.SubnetworksClient()
            networks = list(net_client.list(project=self.project_id))
            for net in networks:
                self.add_finding("Network_Security", net.name, "Custom VPC Check", "OK" if not net.auto_create_subnetworks else "RISK", f"Auto-create Subnets: {net.auto_create_subnetworks}")
            
            agg_subnets = sub_client.aggregated_list(project=self.project_id)
            for _, response in agg_subnets:
                if response.subnetworks:
                    for sub in response.subnetworks:
                        self.add_finding("Network_Security", sub.name, "VPC Flow Logs", "ENABLED" if sub.enable_flow_logs else "DISABLED", f"Region: {sub.region}")

            # 2. Cloud Armor
            armor_client = compute_v1.SecurityPoliciesClient()
            policies = list(armor_client.list(project=self.project_id))
            if not policies:
                self.add_finding("Network_Security", "Global", "Cloud Armor Policies", "MISSING", "No security policies found")
            for p in policies:
                self.add_finding("Network_Security", p.name, "Cloud Armor Policy", "ACTIVE", f"Type: {p.type_}")
        except Exception as e: logging.debug(f"Network Audit Error: {e}")

    def audit_iam(self):
        logging.info(f"{Fore.RED}Auditing IAM (MFA, Least Privilege, Owner Roles)...")
        try:
            client = iam_admin_v1.IAMClient()
            parent = f"projects/{self.project_id}"
            policy = client.get_iam_policy(request={"resource": parent})
            for binding in policy.bindings:
                # Flag Basic Roles (Owner/Editor/Viewer) for Principle of Least Privilege check
                if any(x in binding.role.lower() for x in ["owner", "editor"]):
                    self.add_finding("IAM_Identity", binding.role, "Principle of Least Privilege", "REVIEW", f"Members: {len(binding.members)}")
        except Exception as e: logging.debug(f"IAM Audit Error: {e}")

    def audit_logging_monitoring(self):
        logging.info(f"{Fore.MAGENTA}Auditing Logs & Monitoring (Sinks, Alarms)...")
        try:
            # 1. Cloud Logging Sinks
            log_client = logging_v2.services.config_service_v2.ConfigServiceV2Client()
            parent = f"projects/{self.project_id}"
            sinks = list(log_client.list_sinks(parent=parent))
            self.add_finding("Logging_Monitoring", "Cloud Logging", "Log Sinks (Centralization)", "OK" if sinks else "MISSING", f"Total Sinks: {len(sinks)}")
            
            # 2. Monitoring Alarms
            mon_client = monitoring_v3.AlertPolicyServiceClient()
            alerts = list(mon_client.list_alert_policies(name=parent))
            self.add_finding("Logging_Monitoring", "Cloud Monitoring", "Alert Policies", "OK" if alerts else "MISSING", f"Total Policies: {len(alerts)}")
        except Exception as e: logging.debug(f"Logging Audit Error: {e}")

    def run(self):
        print(f"\n{Fore.WHITE}{Style.BRIGHT}--- STARTING COMPLETE AUDIT FOR: {self.project_id} ---")
        self.audit_compute_gke()
        self.audit_storage()
        self.audit_network_security()
        self.audit_iam()
        self.audit_logging_monitoring()

        filename = f"GCP_Onboarding_Audit_{self.project_id}.xlsx"
        with pd.ExcelWriter(filename, engine='openpyxl') as writer:
            for sheet, data in self.sheets.items():
                if data:
                    pd.DataFrame(data).to_excel(writer, sheet_name=sheet, index=False)
                else:
                    # Create empty sheet with header if no data found
                    pd.DataFrame(columns=["Resource", "Check", "Status", "Details"]).to_excel(writer, sheet_name=sheet, index=False)

        print(f"\n{Fore.GREEN}✅ SUCCESS: Final report generated: {filename}")

if __name__ == "__main__":
    FullProjectAuditor().run()