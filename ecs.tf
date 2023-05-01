resource "aws_ecs_cluster" "ecs" {
  name = "app_cluster"
}

resource "aws_ecs_service" "service" {
  name = "app_service"
  cluster = aws_ecs_cluster.ecs.arn
  launch_type = "FARGATE"
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.td.arn

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  desired_count = 1
  
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.sg1.id]
    subnets = [aws_subnet.sn1.id,aws_subnet.sn2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blazorappdev-lb-target-group.arn
    container_port   = 80
    container_name   = "blazorappdev"
  }
  depends_on = [aws_lb.blazorappdev-lb-web]
}

resource "aws_ecs_task_definition" "td" {
  container_definitions = jsonencode([
    {
      name = "blazorappdev",
      image = "copterbuddy/blazorappdev",
      essential = true
      cpu = 256
      memory = 512,
      portMappings = [
        {
            containerPort = 80
            hostPort = 80
        },
        {
            containerPort = 443
            hostPort = 443
        }
      ],
      environment = [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Development"
        }
        # {
        #   name  = "ASPNETCORE_URLS"
        #   value = "http://+:80"
        # }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my_log_group",
          "awslogs-stream-prefix": "my_log_stream",
          "awslogs-region": "${data.aws_region.current.name}"
        }
      }
    }
  ])
  family = "blazorappdev"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  task_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
}