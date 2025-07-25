# variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "metabase"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "metabase_cpu" {
  description = "CPU units for Metabase ECS task"
  type        = number
  default     = 512
}

variable "metabase_memory" {
  description = "Memory for Metabase ECS task"
  type        = number
  default     = 1024
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "metabase_db_password" {
  description = "Password for Metabase RDS database"
  type        = string
  sensitive   = true
}

variable "metabase_image_url" {
  description = "The full URL of the Metabase Docker image in ECR (e.g., 123456789012.dkr.ecr.eu-west-1.amazonaws.com/metabase_repo:latest)"
  type        = string
}