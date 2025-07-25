# ecr.tf
# Since the ECR repository exists in another region (eu-west-1),
# it should not be managed by this Terraform configuration.
# resource "aws_ecr_repository" "metabase" {
#   name                 = "metabase_repo"
#   image_tag_mutability = "MUTABLE"
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
#
#   tags = {
#     Name        = "${var.project_name}-ecr"
#     Project     = var.project_name
#     Environment = var.environment
#   }
# }