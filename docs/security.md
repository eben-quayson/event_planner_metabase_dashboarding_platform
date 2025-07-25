# Metabase Deployment Security

## Overview

This document outlines the **security measures** for the **Metabase deployment on AWS ECS Fargate in `eu-west-1`**. It prioritizes **data protection, network security, access control, monitoring, and secure deployment practices** for a robust Metabase environment.

---

## 1. Network Security

### VPC Configuration

- **VPC with public and private subnets for isolation:**
  - **Public Subnets:** `10.0.101.0/24`, `10.0.102.0/24`, `10.0.103.0/24` (for ALB internet-facing access).
  - **Private Subnets:** `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` (for ECS tasks and RDS, no direct internet access).

### Connectivity

- **NAT Gateways:** Allow outbound internet from private subnets (e.g., ECR pulls) while maintaining isolation.
- **VPC Endpoints (optional):** Enable private access to AWS services (e.g., ECR, S3) to reduce internet dependency.

### Security Groups

- **ALB Security Group:**
  - Inbound: HTTP (`port 80`) from `0.0.0.0/0`.
  - Outbound: ECS tasks (`port 3000`).
- **ECS Tasks Security Group:**
  - Inbound: From ALB (`port 3000`).
  - Outbound: RDS (`port 5432`), AWS services (ECR, CloudWatch).
- **RDS Security Group:**
  - Inbound: ECS tasks only (`port 5432`).

### ECS IP Management

- **No Public IPs:** `assign_public_ip = false` for ECS tasks, preventing direct internet exposure.

---

## 2. Access Control

### IAM Roles

- **ECS Task Execution Role (`metabase-prod-ecs-task-execution-role`):**
  - ECR pull permissions (`ecr:GetAuthorizationToken`, `ecr:GetDownloadUrlForLayer`, etc.).
  - CloudWatch logging permissions.
- **ECS Task Role (`metabase-prod-ecs-task-role`):**
  - Configurable for additional AWS service access if required by Metabase.
- **Principle of Least Privilege:** Roles are scoped to required actions and resources.

### Database Credentials

- **RDS password (`metabase_db_password`)** is defined in `terraform.tfvars` and marked as sensitive.
- **Recommendation:** Use AWS Secrets Manager to store and rotate credentials.

```hcl
name      = "MB_DB_PASS"
valueFrom = aws_secretsmanager_secret.metabase_db_password.arn
````

---

## 3. Data Protection

### RDS Encryption

* **AWS-managed encryption** for data at rest.
* **SSL/TLS in transit** (enable `sslmode` in Metabase config if needed).

### ECR Image Security

* `scan_on_push = true` in `metabase_repo` for vulnerability scanning.
* Images encrypted using AES-256.

### Sensitive Outputs

* Mark sensitive outputs (e.g., `rds_endpoint`) as `sensitive = true` in `outputs.tf` to prevent accidental exposure.

---

## 4. Application Security

### HTTPS Access

Currently, the ALB uses HTTP (`port 80`). For production, configure HTTPS (`port 443`) with ACM certificates:

```hcl
resource "aws_lb_listener" "metabase_https" {
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
```

### Health Checks

* ECS task definition includes a health check:

  ```bash
  curl -f http://localhost:3000/api/health
  ```

  ensuring only healthy containers receive traffic.

---

## 5. Monitoring and Logging

### CloudWatch Logs

* ECS tasks log to `/aws/ecs/metabase-prod` using the `awslogs` driver.
* Logs include application and health check outputs for debugging.

### ECS Service Events

Monitor with:

```bash
aws ecs describe-services --cluster metabase-prod --services metabase-prod --region eu-west-1
```

---

## 6. Terraform Security

* **State File:** Store `terraform.tfstate` securely (e.g., encrypted S3 with access controls).
* **Sensitive Variables:** Manage variables like `metabase_db_password` securely using Secrets Manager or environment variables.
* **Sensitive Outputs:** Mark outputs (e.g., `rds_endpoint`) as sensitive to prevent CLI/console exposure.

---

## Best Practices and Recommendations

✅ Enable HTTPS on the ALB using ACM certificates.
✅ Store and rotate `metabase_db_password` using AWS Secrets Manager.
✅ Use VPC endpoints for ECR/S3 to reduce internet exposure.
✅ Enforce **least privilege** IAM roles and audit regularly.
✅ Set up CloudWatch Alarms for ECS, ALB, and RDS monitoring.
✅ Enable automated RDS backups:

```hcl
resource "aws_db_instance" "metabase" {
  # ...
  backup_retention_period = 7
}
```

✅ Use **specific image tags** instead of `latest` for ECS deployments:

```hcl
image = "182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:v0.50.0"
```

---

## Known Issues and Mitigations

* **ECR Repository Conflict:** If `metabase_repo` exists:

  ```bash
  terraform import aws_ecr_repository.metabase metabase_repo
  ```
* **Container Provisioning Failures:** Ensure `ecs.tf` is applied after resolving ECR issues.
* **Debugging:** Use CloudWatch Logs and ECS service events for troubleshooting.

---

By following these structured measures, your Metabase deployment on AWS ECS will remain secure, maintainable, and aligned with best practices.


