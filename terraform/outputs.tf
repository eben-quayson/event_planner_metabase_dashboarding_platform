output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.metabase.endpoint
  sensitive   = true
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.metabase.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.metabase.zone_id
}

# The ECR repository is external, so this output is no longer needed.
# output "ecr_repository_url" {
#   description = "URL of the ECR repository"
#   value       = aws_ecr_repository.metabase.repository_url
# }

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.metabase.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.metabase.name
}
