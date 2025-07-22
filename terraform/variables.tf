variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "VPC ID where ECS and RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "db_name" {
  type        = string
  description = "Postgres DB name for Metabase"
}

variable "db_user" {
  type        = string
  description = "Postgres username"
}

variable "db_password" {
  type        = string
  description = "Postgres password"
  sensitive   = true
}

variable "db_host" {
  type        = string
  description = "Postgres host endpoint"
}

variable "ecr_repo_url" {
  type        = string
  description = "ECR repo URL (without tag)"
}

variable "metabase_image_tag" {
  type        = string
  description = "Metabase Docker image tag to deploy"
  default     = "latest"
}
