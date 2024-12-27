resource "aws_ecs_service" "emails_service" {
  name            = "emails-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.emails_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.instances_sg_id]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.provider.name
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "emails_task_definition" {
  family             = "emails-task"
  network_mode       = "awsvpc"
  execution_role_arn = var.ecs_task_execution_role_arn
  cpu                = 256

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "clubsync-emails-api"
      image     = format("%s:%s", var.emails_image_repo, var.emails_image_tag)
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/clubsync-emails-api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      /* environment = [
        {
          name  = "DATABASE_URL"
          value = var.drop_off_points_db_connection_string
        },
      ] */
    }
  ])
}

resource "aws_cloudwatch_log_group" "emails_log_group" {
  name              = "/ecs/clubsync-emails"
  retention_in_days = 7
}