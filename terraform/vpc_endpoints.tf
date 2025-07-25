# vpc_endpoints.tf
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#   
#   tags = {
#     Name = "${var.project_name}-ecr-dkr-endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#   
#   tags = {
#     Name = "${var.project_name}-ecr-api-endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = module.vpc.vpc_id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = module.vpc.private_route_table_ids
#   
#   tags = {
#     Name = "${var.project_name}-s3-endpoint"
#   }
# }

# resource "aws_security_group" "vpc_endpoints" {
#   name_prefix = "${var.project_name}-vpc-endpoints-"
#   vpc_id      = module.vpc.vpc_id
#
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [module.vpc.vpc_cidr_block]
#   }
#
#   tags = {
#     Name = "${var.project_name}-vpc-endpoints-sg"
#   }
# }