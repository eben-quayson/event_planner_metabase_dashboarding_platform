terraform {
  backend "s3" {
    bucket         = "terraform-lock-gyenyame"
    key            = "metabase/terraform.tfstate"
    region         = "eu-west-1"
    use_lockfile   = false
    encrypt        = true
  }
}
