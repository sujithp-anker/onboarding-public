import boto3
import pandas as pd
import concurrent.futures
import time
import logging
from datetime import datetime, timezone
from functools import lru_cache, wraps
from colorama import Fore, Style, init
from botocore.exceptions import ClientError  # <--- FIX 1: Missing Import

init(autoreset=True)
logging.basicConfig(level=logging.INFO, format='%(message)s')

# --- PERFORMANCE DECORATORS ---
def rate_limited(max_per_second):
    min_interval = 1.0 / max_per_second
    def decorator(func):
        last_time_called = [0.0]
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_time_called[0]
            left_to_wait = min_interval - elapsed
            if left_to_wait > 0: time.sleep(left_to_wait)
            ret = func(*args, **kwargs)
            last_time_called[0] = time.time()
            return ret
        return wrapper
    return decorator

@lru_cache(maxsize=1)
def get_regions():
    return [r['RegionName'] for r in boto3.client('ec2').describe_regions()['Regions']]

# --- AUDIT ENGINE ---
class AnkercloudAuditor:
    def __init__(self):
        self.session = boto3.Session()
        try:
            self.account_id = self.session.client('sts').get_caller_identity()['Account']
        except:
            self.account_id = "Unknown"
        
        # FIX 2: Standardized keys to match the audit_region logic exactly
        self.sheets = {
            "Identity_IAM": [],
            "Compute_EC2_LB": [],
            "Database_RDS_Dynamo": [],
            "Network_VPC": [],
            "Storage_S3": [],
            "Monitoring_CloudTrail": [],
            "CloudWatch_Log_Retention": [], # <--- Ensure this matches line 112
            "Security_ACM_Config": [],
            "Billing_Org": []
        }

    def add_finding(self, sheet, region, service, resource_id, check, status, details):
        if sheet in self.sheets:
            self.sheets[sheet].append({
                "Region": region, "Service": service, "Resource ID": resource_id,
                "Check": check, "Status": status, "Details": details
            })

    @rate_limited(5)
    def audit_region(self, region):
        logging.info(f"{Fore.CYAN}Auditing Region: {region}")
        try:
            ec2 = self.session.client('ec2', region_name=region)
            rds = self.session.client('rds', region_name=region)
            elbv2 = self.session.client('elbv2', region_name=region)
            logs = self.session.client('logs', region_name=region)
            cw = self.session.client('cloudwatch', region_name=region)

            # 1. EC2 & EBS
            instances = ec2.describe_instances()['Reservations']
            for res in instances:
                for inst in res['Instances']:
                    iid = inst['InstanceId']
                    tp = ec2.describe_instance_attribute(InstanceId=iid, Attribute='disableApiTermination')['DisableApiTermination']['Value']
                    self.add_finding("Compute_EC2_LB", region, "EC2", iid, "Termination Protection", "SAFE" if tp else "RISK", f"Protected: {tp}")
                    
                    tags = {t['Key']: t['Value'] for t in inst.get('Tags', [])}
                    self.add_finding("Compute_EC2_LB", region, "EC2", iid, "Tagging Convention", "OK" if "Name" in tags else "MISSING", f"Tags: {tags}")
                    
                    for dev in inst.get('BlockDeviceMappings', []):
                        vol = ec2.describe_volumes(VolumeIds=[dev['Ebs']['VolumeId']])['Volumes'][0]
                        self.add_finding("Compute_EC2_LB", region, "EBS", vol['VolumeId'], "Encryption", "SAFE" if vol['Encrypted'] else "RISK", f"Encrypted: {vol['Encrypted']}")
                    
                    alarms = cw.describe_alarms(AlarmNamePrefix=iid)['MetricAlarms']
                    self.add_finding("Compute_EC2_LB", region, "EC2", iid, "StatusCheck Alarms", "FOUND" if alarms else "MISSING", f"Alarms: {len(alarms)}")

            # 2. RDS Deep Audit
            dbs = rds.describe_db_instances()['DBInstances']
            for db in dbs:
                dbid = db['DBInstanceIdentifier']
                self.add_finding("Database_RDS_Dynamo", region, "RDS", dbid, "Multi-AZ Enabled", "SAFE" if db['MultiAZ'] else "RISK", f"MultiAZ: {db['MultiAZ']}")
                self.add_finding("Database_RDS_Dynamo", region, "RDS", dbid, "Deletion Protection", "SAFE" if db['DeletionProtection'] else "RISK", f"Status: {db['DeletionProtection']}")
                self.add_finding("Database_RDS_Dynamo", region, "RDS", dbid, "Automated Backups", "OK" if db['BackupRetentionPeriod'] >= 7 else "LOW", f"Days: {db['BackupRetentionPeriod']}")
                
                pg_name = db['DBParameterGroups'][0]['DBParameterGroupName']
                is_custom = not pg_name.startswith('default.')
                self.add_finding("Database_RDS_Dynamo", region, "RDS", dbid, "Custom Parameter Group", "OK" if is_custom else "RISK", f"PG: {pg_name}")

            # 3. Load Balancers
            lbs = elbv2.describe_load_balancers()['LoadBalancers']
            for lb in lbs:
                arn, name = lb['LoadBalancerArn'], lb['LoadBalancerName']
                attr = elbv2.describe_load_balancer_attributes(LoadBalancerArn=arn)['Attributes']
                acc_logs = next((a['Value'] for a in attr if a['Key'] == 'access_logs.s3.enabled'), 'false')
                self.add_finding("Compute_EC2_LB", region, "ELB", name, "Access Logs", "ENABLED" if acc_logs == 'true' else "DISABLED", f"S3 Access Logs: {acc_logs}")

            # 4. Regional Log Retention (The sheet name fix is here)
            for lg in logs.describe_log_groups()['logGroups']:
                lname = lg['logGroupName']
                ret = lg.get('retentionInDays', "Indefinite")
                is_prod = any(x in lname.lower() for x in ['vpc', 'config', 'prod', 'sql'])
                target = 30 if is_prod else 7
                status = "OK" if ret == target else "REVIEW"
                self.add_finding("CloudWatch_Log_Retention", region, "CloudWatch", lname, "Retention Policy", status, f"Current: {ret} days")

        except Exception as e:
            logging.error(f"Error in {region}: {str(e)}")

    def audit_global(self):
        logging.info(f"{Fore.YELLOW}Scanning Global Services (IAM/S3/CloudTrail)...")
        
        # S3 with Access Denied Protection
        s3 = self.session.client('s3')
        try:
            buckets = s3.list_buckets()['Buckets']
            for b in buckets:
                name = b['Name']
                try:
                    ver = s3.get_bucket_versioning(Bucket=name).get('Status', 'Disabled')
                    self.add_finding("Storage_S3", "Global", "S3", name, "Versioning", "OK" if ver == "Enabled" else "RISK", f"Status: {ver}")
                except ClientError:
                    self.add_finding("Storage_S3", "Global", "S3", name, "Versioning", "ACCESS_DENIED", "Policy prevents checking attributes")
        except Exception as e:
            logging.error(f"Could not list buckets: {str(e)}")

        # IAM & CloudTrail
        iam = self.session.client('iam')
        summary = iam.get_account_summary()['SummaryMap']
        self.add_finding("Identity_IAM", "Global", "IAM", "Account", "Root MFA", "ENABLED" if summary.get('AccountMFAEnabled') else "DISABLED", "Check Root Protection")

        ct = self.session.client('cloudtrail', region_name='us-east-1')
        trails = ct.describe_trails()['trailList']
        for t in trails:
            is_global = t.get('IsMultiRegionTrail', False)
            status = ct.get_trail_status(Name=t['TrailARN']).get('IsLogging', False)
            self.add_finding("Monitoring_CloudTrail", "Global", "CloudTrail", t['Name'], "Global Logging Status", "OK" if (is_global and status) else "RISK", f"Global: {is_global}")

    def run(self):
        print(f"{Fore.MAGENTA}--- STARTING FINAL AUTOMATED AUDIT ---")
        self.audit_global()
        regions = get_regions()
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            executor.map(self.audit_region, regions)

        filename = f"Ankercloud_Onboarding_Audit_{self.account_id}.xlsx"
        with pd.ExcelWriter(filename, engine='openpyxl') as writer:
            for sheet, data in self.sheets.items():
                if data: pd.DataFrame(data).to_excel(writer, sheet_name=sheet, index=False)
        print(f"{Fore.GREEN}✅ SUCCESS: Report generated: {filename}")

if __name__ == "__main__":
    AnkercloudAuditor().run()
