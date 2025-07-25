# 🚀 Metabase on AWS ECS Fargate with Terraform

This repository automates deploying **Metabase** on **AWS ECS Fargate** using **Terraform**, connected to **PostgreSQL RDS**, storing Docker images in **AWS ECR**, and securely exposing Metabase via an **Application Load Balancer (ALB)** within a **private VPC architecture**.

---

## 📌 Features

✅ **Containerized Metabase** on ECS Fargate
✅ **ALB** with auto-provisioned target groups and listeners
✅ **PostgreSQL RDS** for persistent storage
✅ Private **VPC with public and private subnets** for secure isolation
✅ **CloudWatch Logs** for observability and debugging
✅ **ECR** for secure image hosting with vulnerability scanning
✅ Extensible for **CI/CD pipelines** and HTTPS integration

---

## ⚙️ Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (configured)
* [Docker](https://docs.docker.com/get-docker/)
* An AWS account with:

  * ECS Fargate, ECR, RDS, ACM, and VPC permissions
  * Optional: S3 for Terraform state storage

---

## 🚀 Deployment Steps

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd metabase_fargate_deployment/terraform
```

---

### 2️⃣ Configure variables

Edit `variables.tf` or create a `terraform.tfvars` file:

```hcl
aws_region = "eu-west-1"

db_name     = "metabase_db"
db_user     = "metabase_user"
db_password = "your_db_password"

ecr_repo_url       = "182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo"
metabase_image_tag = "latest"
```

✅ Ensure the **RDS database is accessible** from ECS tasks.

---

### 3️⃣ Initialize Terraform

```bash
terraform init
```

---

### 4️⃣ Preview changes

```bash
terraform plan
```

---

### 5️⃣ Apply changes

```bash
terraform apply
```

Type `yes` when prompted.

---

### 6️⃣ Access Metabase

After deployment, Terraform will output the **ALB DNS name**:

```
alb_dns_name = metabase-prod-xxxxxxxx.eu-west-1.elb.amazonaws.com
```

Open:

```
http://metabase-prod-xxxxxxxx.eu-west-1.elb.amazonaws.com
```

to access your **Metabase dashboard**.

---

## 🪵 Logs & Debugging

* Navigate to **CloudWatch → Log Groups → /aws/ecs/metabase-prod** to view container logs.
* Check ALB target group health:

  * Healthy targets = ECS tasks are functioning.
  * Unhealthy targets:

    * Verify RDS connectivity.
    * Check security groups.
    * Confirm environment variables.

---

## 🔧 Useful Commands

### Deploy Metabase Image to ECR

```bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com

docker pull metabase/metabase:latest
docker tag metabase/metabase:latest <account-id>.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest
```

---

## 💡 Notes

✅ **awsvpc network mode** is used for ECS tasks, providing ENI-based networking within your VPC.
✅ The RDS security group must allow inbound `5432` from the ECS tasks security group.
✅ Metabase stores data in **PostgreSQL RDS**, ensuring persistence across container restarts.

---

## 🛠 Extending

* Add **HTTPS** using ACM and ALB HTTPS listeners.
* Integrate **GitHub Actions** for:

  * Automated Docker image builds and ECR pushes.
  * Automated `terraform apply` pipelines on PR merge.
* Enable **RDS automated backups** and monitoring alarms.
* Configure **VPC Endpoints for ECR and S3** for reduced internet dependency.

---

## ✨ License

MIT

---

If you want, I can also prepare:
✅ A **clean diagram** of your architecture to add to the README.
✅ A **`SECURITY.md`** matching this architecture.
✅ A **GitHub Actions workflow** to automate ECR + Terraform deploys.


