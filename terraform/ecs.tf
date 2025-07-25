# ecs.tf 
     resource "aws_ecs_task_definition" "metabase" {
       family                   = "${var.project_name}-${var.environment}"
       network_mode             = "awsvpc"
       requires_compatibilities = ["FARGATE"]
       cpu                      = 512
       memory                   = 1024
       execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
       task_role_arn           = aws_iam_role.ecs_task_role.arn

       container_definitions = jsonencode([
         {
           name  = "metabase"
           image = var.metabase_image_url
           
           essential = true
           
           portMappings = [
             {
               containerPort = 3000
               protocol      = "tcp"
             }
           ]

           environment = [
             {
               name  = "MB_DB_TYPE"
               value = "postgres"
             },
             {
               name  = "MB_DB_DBNAME"
               value = aws_db_instance.metabase.db_name
             },
             {
               name  = "MB_DB_PORT"
               value = tostring(aws_db_instance.metabase.port)
             },
             {
               name  = "MB_DB_USER"
               value = aws_db_instance.metabase.username
             },
             {
               name  = "MB_DB_PASS"
               value = var.metabase_db_password # Note: Consider using AWS Secrets Manager for production
             },
             {
               name  = "MB_DB_HOST"
               value = aws_db_instance.metabase.address
             }
           ]

           logConfiguration = {
             logDriver = "awslogs"
             options = {
               awslogs-group         = aws_cloudwatch_log_group.ecs.name
               awslogs-region        = var.aws_region
               awslogs-stream-prefix = "ecs"
             }
           }

           healthCheck = {
             command = [
               "CMD-SHELL",
               "curl -f http://localhost:3000/api/health || exit 1"
             ]
             interval    = 30
             timeout     = 5
             retries     = 3
             startPeriod = 60
           }
         }
       ])

       tags = {
         Name        = "${var.project_name}-task-definition"
         Project     = var.project_name
         Environment = var.environment
       }
     }

resource "aws_ecs_cluster" "metabase" {
  name = "${var.project_name}-${var.environment}"

  tags = {
    Name        = "${var.project_name}-cluster"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecs_service" "metabase" {
  name            = "${var.project_name}-${var.environment}"
  cluster         = aws_ecs_cluster.metabase.id
  task_definition = aws_ecs_task_definition.metabase.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.metabase.arn
    container_name   = "metabase"
    container_port   = 3000
  }

  # Ensures the service waits for the ALB listener to be fully created
  # before attempting to register targets, preventing race conditions.
  depends_on = [aws_lb_listener.metabase]

  tags = {
    Name        = "${var.project_name}-service"
    Project     = var.project_name
    Environment = var.environment
  }
}