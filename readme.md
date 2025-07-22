# 🚀 Metabase ECS Fargate Deployment with Terraform

This repository automates deploying **Metabase** on **AWS ECS Fargate** using **Terraform**, connecting it to a **PostgreSQL RDS** instance, and exposing it securely via **AWS ALB**.

---

## 📌 Features

✅ Containerized **Metabase** on ECS Fargate  
✅ Auto-provisioned **ALB**, Target Groups, Listeners  
✅ Connects to **Postgres RDS** within your VPC  
✅ Configurable environment variables via Terraform  
✅ Uses **CloudWatch Logs** for debugging  
✅ Easily extensible for CI/CD pipelines

---

## 🗂 Folder Structure

```

metabase\_fargate\_deployment/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── modules/
│       └── ecs\_metabase/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
│
└── README.md

````

---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (authenticated)
- [Docker](https://docs.docker.com/get-docker/)
- An AWS account with:
  - ECS Fargate permissions
  - ECR for image hosting
  - RDS PostgreSQL database accessible to ECS

---

## 🚀 Deployment Steps

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd metabase_fargate_deployment/terraform
````

---

### 2️⃣ Configure variables

Edit `terraform/variables.tf` or use a `terraform.tfvars` file:

```hcl
region = "eu-west-1"
vpc_id = "vpc-xxxxxxx"

public_subnet_ids = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]

db_name     = "your_db_name"
db_user     = "your_db_user"
db_password = "your_db_password"
db_host     = "your-db.xxxxxx.eu-west-1.rds.amazonaws.com"

ecr_repo_url        = "182399707265.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo"
metabase_image_tag  = "latest"
```

✅ **Ensure `db_host` does NOT contain `http://`.**

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
alb_dns_name = metabase-alb-xxxxxxxxxx.eu-west-1.elb.amazonaws.com
```

Open:

```
http://metabase-alb-xxxxxxxxxx.eu-west-1.elb.amazonaws.com
```

to access your **Metabase dashboard**.

---

## 🪵 Logs & Debugging

* Navigate to **CloudWatch → Log Groups → /ecs/metabase** to see container logs.
* Check **ALB Target Group Health**:

  * Healthy targets indicate ECS tasks are running correctly.
  * If unhealthy, check:

    * RDS connectivity.
    * Security group rules.
    * Environment variable correctness.

---

## 🔧 Useful Commands

### Deploy image to ECR

```bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com

docker pull metabase/metabase:latest
docker tag metabase/metabase:latest <account-id>.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest
```

---

## 💡 Notes

✅ This setup uses **Metabase on ECS Fargate** with **awsvpc network mode**.
✅ Ensure **RDS security group** allows inbound `5432` from ECS tasks' security group.
✅ Metabase data is stored in your **Postgres database**, not locally within the container.

---

## 🛠 Extending

* Add HTTPS using ACM and redirect rules in your ALB.
* Integrate with GitHub Actions for CI/CD:

  * Auto-build and push Metabase images to ECR.
  * Terraform apply pipeline on PR merge.
* Add backup and monitoring alarms for your RDS instance.

---

## ✨ License

MIT

