Metabase Deployment Security
Overview
This document details the security measures implemented for the Metabase deployment on AWS ECS Fargate in the eu-west-1 region. The configuration prioritizes data protection, network security, access control, and monitoring to ensure a secure environment for the Metabase application.
Security Measures
1. Network Security

VPC Configuration:
The deployment uses a VPC with separate public and private subnets to isolate resources.
Public Subnets (10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24): Host the ALB for internet-facing access.
Private Subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24): Host ECS tasks and the RDS instance, preventing direct internet access.


NAT Gateways: Allow outbound internet access from private subnets (e.g., for ECR image pulls) while keeping resources isolated.
VPC Endpoints (Optional): Configurable for private access to AWS services (e.g., ECR, S3) to eliminate internet dependency and reduce attack surface.
Security Groups:
ALB Security Group: Allows inbound HTTP (port 80) from 0.0.0.0/0 and outbound to ECS tasks (port 3000).
ECS Tasks Security Group: Allows inbound from the ALB (port 3000) and outbound to RDS (port 5432) and AWS services (e.g., ECR, CloudWatch).
RDS Security Group: Allows inbound from ECS tasks (port 5432) only, restricting access to authorized services.


No Public IPs for ECS: ECS tasks use assign_public_ip = false, ensuring they are not directly accessible from the internet.

2. Access Control

IAM Roles:
ECS Task Execution Role (metabase-prod-ecs-task-execution-role):
Permissions: ecr:GetAuthorizationToken, ecr:BatchCheckLayerAvailability, ecr:GetDownloadUrlForLayer, ecr:BatchGetImage for pulling images from metabase_repo.
CloudWatch permissions: logs:CreateLogStream, logs:PutLogEvents for logging.


ECS Task Role (metabase-prod-ecs-task-role): Configurable for additional AWS service access if needed by the Metabase application.
Principle of Least Privilege: Roles are scoped to specific actions and resources.


Database Credentials:
The RDS password (metabase_db_password) is defined in terraform.tfvars and marked as sensitive in Terraform outputs.
Recommendation: Use AWS Secrets Manager to store and rotate the password, updating the ECS task definition to reference the secret ARN:{
  name  = "MB_DB_PASS"
  valueFrom = aws_secretsmanager_secret.metabase_db_password.arn
}





3. Data Protection

RDS Encryption:
The RDS PostgreSQL instance (db.t3.micro, 20 GB) uses AWS-managed encryption for data at rest.
Data in transit is protected via PostgreSQL’s default SSL/TLS support (ensure sslmode is enabled in Metabase configuration if required).


ECR Image Security:
The metabase_repo repository has scan_on_push = true, enabling AWS ECR to scan images for vulnerabilities on push.
Encryption: Images are encrypted using AES-256 (as specified in the repository configuration).


Sensitive Outputs:
The RDS endpoint (rds_endpoint) is marked as sensitive in outputs.tf to prevent accidental exposure in Terraform outputs.



4. Application Security

HTTP Access: The ALB currently uses HTTP (port 80). For production, configure an HTTPS listener (port 443) with an SSL certificate from AWS Certificate Manager (ACM):resource "aws_lb_listener" "metabase_https" {
  load_balancer_arn = aws_lb.metabase.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "<acm-certificate-arn>"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase.arn
  }
}


Health Check: The ECS task definition includes a health check (curl -f http://localhost:3000/api/health), ensuring only healthy containers receive traffic.

5. Monitoring and Logging

CloudWatch Logs:
ECS tasks log to /aws/ecs/metabase-prod with the awslogs driver.
Logs include application and health check output, enabling debugging of container failures.


ECS Service Events: The ECS service logs deployment events (e.g., task failures) to the AWS Console or via:aws ecs describe-services --cluster metabase-prod --services metabase-prod --region eu-west-1



6. Terraform Security

State File: The Terraform state file (terraform.tfstate) contains sensitive data (e.g., RDS endpoint). Store it securely (e.g., in an S3 bucket with encryption and access controls).
Variables: Sensitive variables like metabase_db_password in terraform.tfvars should be managed via secure methods (e.g., AWS Secrets Manager or environment variables).
Outputs: Sensitive outputs (e.g., rds_endpoint) are marked as sensitive to prevent exposure.

Best Practices and Recommendations

Enable HTTPS: Add an HTTPS listener to the ALB with an ACM certificate for secure communication.
Secrets Management: Use AWS Secrets Manager for metabase_db_password to automate rotation and avoid hardcoding.
Network Hardening: Enable VPC Endpoints for ECR and S3 to eliminate NAT Gateway dependency and reduce internet exposure.
IAM Policies: Regularly audit IAM roles to ensure least privilege.
Monitoring: Set up CloudWatch Alarms for ECS task failures, ALB errors, or RDS performance metrics.
Backup: Enable automated backups for the RDS instance in rds.tf:resource "aws_db_instance" "metabase" {
  # ...
  backup_retention_period = 7
}


Image Tagging: Use specific image tags (e.g., v0.50.0) instead of latest in ecs.tf for predictable deployments:image = "182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:v0.50.0"



