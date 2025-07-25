# Metabase Deployment Architecture

## Overview

This document describes the **architecture of the Metabase application deployed on AWS ECS Fargate in `eu-west-1`**. The architecture leverages AWS managed services to provide a **scalable, highly available, and secure environment** for **Metabase**, a business intelligence tool.

---

## Components

### 1️⃣ Virtual Private Cloud (VPC)

**Purpose:** Secure, isolated network for all resources.

**Configuration:**

- **CIDR Block:** `10.0.0.0/16`
- **Public Subnets:**  
  - `10.0.101.0/24`, `10.0.102.0/24`, `10.0.103.0/24` (`eu-west-1a`, `eu-west-1b`, `eu-west-1c`)
- **Private Subnets:**  
  - `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` (`eu-west-1a`, `eu-west-1b`, `eu-west-1c`)
- **NAT Gateways:** In public subnets for private subnet internet access (e.g., ECR pulls).
- **Optional VPC Endpoints:** For private access to AWS services (ECR, S3) to reduce internet dependency.

---

### 2️⃣ Elastic Container Service (ECS) Fargate

**Purpose:** Runs the Metabase container in a serverless environment.

**Configuration:**

- **Cluster:** `metabase-prod`
- **Task Definition:**
  - **Family:** `metabase-prod`
  - **CPU:** 512 units
  - **Memory:** 1024 MB
  - **Container:**  
    - Image: `182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest`
    - Network Mode: `awsvpc` (private subnets, no public IP)
    - Environment Variables: `MB_DB_TYPE`, `MB_DB_DBNAME`, `MB_DB_PORT`, `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_HOST`
    - Health Check: HTTP `/api/health` on port `3000`
- **Service:**
  - Name: `metabase-prod`
  - Desired Count: `1`
  - Launch Type: `Fargate`
  - Network: Private subnets with security groups allowing inbound from ALB on `port 3000`
- **Logging:** ECS tasks log to CloudWatch Logs (`/aws/ecs/metabase-prod`).

---

### 3️⃣ Application Load Balancer (ALB)

**Purpose:** Distributes HTTP traffic to ECS tasks.

**Configuration:**

- **Name:** `metabase-prod`
- **Type:** Application Load Balancer
- **Subnets:** Public subnets for internet accessibility
- **Listener:** HTTP on `port 80`, forwarding to target group
- **Target Group:** Routes traffic to ECS tasks on `port 3000`
- **Security Group:** Allows inbound HTTP (`port 80`) from `0.0.0.0/0`
- **DNS Name:**  
  `metabase-prod-<random-id>.eu-west-1.elb.amazonaws.com` (accessible via `alb_dns_name` Terraform output)

---

### 4️⃣ RDS PostgreSQL

**Purpose:** Stores Metabase application data.

**Configuration:**

- **Instance Class:** `db.t3.micro`
- **Storage:** 20 GB
- **Engine:** PostgreSQL
- **Subnets:** Private subnets
- **Security Group:** Allows inbound `port 5432` from ECS tasks security group
- **Endpoint:** Accessible via Terraform output `rds_endpoint` (marked sensitive)
- **Credentials:** Managed via `metabase_db_password` variable

---

### 5️⃣ Elastic Container Registry (ECR)

**Purpose:** Stores the Metabase Docker image.

**Configuration:**

- **Repository:** `metabase_repo` (account `182399707265`, region `eu-west-1`)
- **Image Tag Mutability:** Mutable
- **Scan on Push:** Enabled
- **Image:**  
  `182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest`

---

### 6️⃣ IAM Roles

- **ECS Task Execution Role:**
  - Allows ECS tasks to pull images from ECR and write logs to CloudWatch.
  - Permissions:
    - `ecr:GetAuthorizationToken`
    - `ecr:BatchCheckLayerAvailability`
    - `ecr:GetDownloadUrlForLayer`
    - `ecr:BatchGetImage`
    - `logs:CreateLogStream`
    - `logs:PutLogEvents`
- **ECS Task Role:**
  - Grants permissions for the Metabase container to interact with AWS services if required.

---

### 7️⃣ CloudWatch Logs

**Purpose:** Stores logs for monitoring and debugging.

**Configuration:**

- **Log Group:** `/aws/ecs/metabase-prod`
- **Stream Prefix:** `ecs`

---

## Network Flow

- **User Access:** Users access Metabase via the ALB DNS (`http://metabase-prod-<random-id>.eu-west-1.elb.amazonaws.com`).
- **ALB ➔ ECS:** ALB forwards HTTP traffic (`port 80`) to ECS tasks (`port 3000`).
- **ECS ➔ RDS:** Metabase container connects to RDS PostgreSQL on `port 5432` for data storage.
- **ECS ➔ ECR:** ECS tasks pull the `metabase_repo:latest` image from ECR during deployment via NAT Gateways.
- **Logging:** ECS tasks send logs to CloudWatch Logs for monitoring.

---

## Deployment Workflow

- **Infrastructure as Code:** Managed via Terraform in `metabase-deployment/`.
- **Key Files:**  
  `main.tf`, `ecs.tf`, `ecr.tf`, `alb.tf`, `rds.tf`, `iam.tf`, `security_groups.tf`, `cloudwatch.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`.
- **Variables:** Defined in `terraform.tfvars` (e.g., `project_name = "metabase"`, `environment = "prod"`, `aws_region = "eu-west-1"`).
- **Image Management:** Metabase image (`metabase_repo:latest`) stored in ECR and pulled by ECS tasks.
- **Key Outputs:** `alb_dns_name` for access, `rds_endpoint` for DB connectivity.

---

## Scalability and Availability

✅ **High Availability:** Resources distributed across `eu-west-1a`, `eu-west-1b`, `eu-west-1c`.  
✅ **Scalability:** Adjust `desired_count` in ECS service; ALB distributes traffic across tasks.  
✅ **Fargate:** Serverless compute scales automatically with task demand.

---

## Diagram

```

\[Internet]
↓
\[ALB (HTTP:80, Public Subnets)]
↓
\[ECS Fargate (metabase-prod, Private Subnets, Port 3000)]
↓
\[RDS PostgreSQL (Private Subnets, Port 5432)]
↓
\[ECR (metabase\_repo\:latest)] ⇆ \[CloudWatch Logs]

```

---

This structure ensures **clarity for engineers, DevOps, and auditors** reviewing your Metabase deployment while aligning with **AWS best practices** for scalability, observability, and security.
