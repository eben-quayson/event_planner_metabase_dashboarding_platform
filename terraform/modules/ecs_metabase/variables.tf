variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  default = []
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_host" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

variable "metabase_image_tag" {
  type = string
}
