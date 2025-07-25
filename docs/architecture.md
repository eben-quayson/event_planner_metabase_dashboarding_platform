Metabase Deployment Architecture
Overview
This document outlines the architecture of the Metabase application deployed on AWS using ECS Fargate. The deployment leverages AWS services to provide a scalable, highly available, and secure environment for running Metabase, a business intelligence tool, in the eu-west-1 region.
Components
1. Virtual Private Cloud (VPC)

Purpose: Provides a secure, isolated network environment for all resources.
Configuration:
CIDR Block: 10.0.0.0/16
Public Subnets: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24 (in eu-west-1a, eu-west-1b, eu-west-1c)
Private Subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24 (in eu-west-1a, eu-west-1b, eu-west-1c)
NAT Gateways: Deployed in public subnets to allow private subnet resources to access the internet (e.g., for ECR image pulls).
Optional VPC Endpoints: Configurable for private access to AWS services (e.g., ECR, S3) to reduce NAT Gateway dependency.



2. Elastic Container Service (ECS) Fargate

Purpose: Runs the Metabase application container in a serverless environment.
Configuration:
Cluster: metabase-prod
Task Definition:
Family: metabase-prod
CPU: 512 units
Memory: 1024 MB
Container: Runs the metabase_repo:latest image from ECR (182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest).
Network Mode: awsvpc (private subnets, no public IP).
Environment Variables: Configured for PostgreSQL connectivity (MB_DB_TYPE, MB_DB_DBNAME, MB_DB_PORT, MB_DB_USER, MB_DB_PASS, MB_DB_HOST).
Health Check: HTTP check on /api/health (port 3000).


Service:
Name: metabase-prod
Desired Count: 1 task
Launch Type: Fargate
Network: Private subnets with security group allowing outbound traffic and inbound from the ALB on port 3000.


Logging: Tasks log to CloudWatch Logs (/aws/ecs/metabase-prod).



3. Application Load Balancer (ALB)

Purpose: Distributes incoming HTTP traffic to the ECS service.
Configuration:
Name: metabase-prod
Type: Application Load Balancer
Subnets: Public subnets for internet accessibility.
Listener: HTTP on port 80, forwarding to the target group.
Target Group: Routes traffic to ECS tasks on port 3000.
Security Group: Allows inbound HTTP (port 80) from 0.0.0.0/0.
DNS Name: metabase-prod-<random-id>.eu-west-1.elb.amazonaws.com (accessible via Terraform output alb_dns_name).



4. RDS PostgreSQL

Purpose: Stores Metabase application data.
Configuration:
Instance Class: db.t3.micro
Allocated Storage: 20 GB
Engine: PostgreSQL
Subnets: Private subnets for security.
Security Group: Allows inbound traffic on port 5432 from the ECS tasks security group.
Endpoint: Accessible via Terraform output rds_endpoint (sensitive).
Credentials: Username and password configured via metabase_db_password variable.



5. Elastic Container Registry (ECR)

Purpose: Stores the Metabase Docker image.
Configuration:
Repository: metabase_repo (in account 182399707265, region eu-west-1)
Image Tag Mutability: Mutable
Scan on Push: Enabled for vulnerability scanning.
Image: 182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest



6. IAM Roles

ECS Task Execution Role: Allows ECS tasks to pull images from ECR and write logs to CloudWatch.
Permissions: ecr:GetAuthorizationToken, ecr:BatchCheckLayerAvailability, ecr:GetDownloadUrlForLayer, ecr:BatchGetImage, logs:CreateLogStream, logs:PutLogEvents.


ECS Task Role: Grants permissions for the Metabase container to interact with AWS services (if needed).

7. CloudWatch Logs

Purpose: Stores logs from ECS tasks for monitoring and debugging.
Configuration:
Log Group: /aws/ecs/metabase-prod
Stream Prefix: ecs



Network Flow

User Access: Users access Metabase via the ALB DNS name (http://metabase-prod-<random-id>.eu-west-1.elb.amazonaws.com) over HTTP.
ALB to ECS: The ALB forwards HTTP traffic (port 80) to the ECS tasks (port 3000) via the target group.
ECS to RDS: The Metabase container connects to the RDS PostgreSQL instance (port 5432) in private subnets for data storage.
ECS to ECR: Tasks pull the metabase_repo:latest image from ECR during deployment, using NAT Gateways for internet access from private subnets.
Logging: ECS tasks send logs to CloudWatch Logs for monitoring.

Deployment Workflow

Terraform: Infrastructure is defined and managed via Terraform in the metabase-deployment directory.
Key files: main.tf, ecs.tf, ecr.tf, alb.tf, rds.tf, iam.tf, security_groups.tf, cloudwatch.tf, variables.tf, outputs.tf, terraform.tfvars.
Variables: Defined in terraform.tfvars (e.g., project_name = "metabase", environment = "prod", aws_region = "eu-west-1").


Image Management: The Metabase image is stored in ECR (metabase_repo:latest) and pulled by ECS tasks.
Outputs: Key outputs include alb_dns_name (for accessing Metabase) and rds_endpoint (for database connectivity).

Scalability and Availability

High Availability: Resources are distributed across multiple availability zones (eu-west-1a, eu-west-1b, eu-west-1c) for redundancy.
Scalability: The ECS service can scale by adjusting desired_count. The ALB distributes traffic across tasks.
Fargate: Serverless compute eliminates server management, scaling with task demand.

Diagram
[Internet] --> [ALB (HTTP:80, Public Subnets)]
                     |
                     v
[ECS Fargate (metabase-prod, Private Subnets, Port 3000)]
                     |
                     v
[RDS PostgreSQL (Private Subnets, Port 5432)]
                     |
                     v
[ECR (metabase_repo:latest)] <--> [CloudWatch Logs]
