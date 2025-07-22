module "ecs_metabase" {
  source = "./modules/ecs_metabase"

  region              = var.region
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.public_subnet_ids
  public_subnet_ids   = var.public_subnet_ids

  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
  db_host             = var.db_host

  ecr_repo_url        = var.ecr_repo_url
  metabase_image_tag  = var.metabase_image_tag
}
