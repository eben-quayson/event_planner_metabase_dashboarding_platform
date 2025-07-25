# rds.tf
resource "aws_db_subnet_group" "metabase" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_db_instance" "metabase" {
  identifier = "${var.project_name}-${var.environment}"

  engine         = "postgres"
  engine_version = "17.4"
  instance_class = var.rds_instance_class
  
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_allocated_storage * 5
  storage_type         = "gp2"
  storage_encrypted    = true

  db_name  = "metabase"
  username = "metabase"
  password = var.metabase_db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.metabase.name
  publicly_accessible    = false

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  performance_insights_enabled = false
  monitoring_interval         = 0

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  copy_tags_to_snapshot    = true

  tags = {
    Name        = "${var.project_name}-database"
    Project     = var.project_name
    Environment = var.environment
  }
}