resource "aws_ecs_cluster" "ecs" {
  name = "app_cluster"
}

resource "aws_ecs_service" "blazor_app_aws_ecs_service" {
  name = "blazor_client_aws_ecs_service"
  cluster = aws_ecs_cluster.ecs.arn
  launch_type = "FARGATE"
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.td.arn
  depends_on = [aws_lb.blazordev-lb-web, aws_lb_listener.blazorappdev-lb-listener]

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
}

resource "aws_ecs_service" "blazor_service_aws_ecs_service" {
  name = "blazor_service_aws_ecs_service"
  cluster = aws_ecs_cluster.ecs.arn
  launch_type = "FARGATE"
  enable_execute_command = true
  task_definition = aws_ecs_task_definition.td2.arn
  depends_on = [aws_lb.blazordev-lb-web, aws_lb_listener.blazorservicedev-lb-listener]

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  desired_count = 1
  
  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.sg1.id]
    subnets = [aws_subnet.sn1.id,aws_subnet.sn2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blazorservicedev-lb-target-group.arn
    container_port   = 81
    container_name   = "blazorservicedev"
  }
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
      ],
      environment = [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Prod"
        },
        {
          name  = "BaseSettings__Url"
          value = "http://${data.aws_lb.blazordev-lb-web.dns_name}:81"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my_log_group",
          "awslogs-stream-prefix": "my_log_stream_client",
          "awslogs-region": "${data.aws_region.current.name}"
        }
      }
    }
  ])
  family = "blazorclientdev"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  task_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "td2" {
  container_definitions = jsonencode([
    {
      name = "blazorservicedev",
      image = "copterbuddy/blazorservicedev",
      essential = true
      cpu = 256
      memory = 512,
      portMappings = [
        {
            containerPort = 81
            hostPort = 81
        }
      ],
      environment = [
        {
          "name": "ASPNETCORE_ENVIRONMENT",
          "value": "Prod"
        },
        {
          name  = "ConnectionStrings__DefaultConnection"
          value = "Server=tiny.db.elephantsql.com;Port=5432;Database=egpcfbsw;User Id=egpcfbsw;Password=XwcSRItO6L3AP0PNQjyOI3zt6mKJ8sgr;"
        },
        {
          name  = "Jwt__Issuer"
          value = "copterbuddy.host"
        },
        {
          name  = "Jwt__Audience"
          value = "copterbuddy.user"
        },
        {
          name  = "Jwt__Key"
          value = "copterbuddy.token"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my_log_group",
          "awslogs-stream-prefix": "my_log_stream_service",
          "awslogs-region": "${data.aws_region.current.name}"
        }
      }
    }
  ])
  family = "blazorservicedev"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  task_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
  execution_role_arn = "arn:aws:iam::024763395437:role/ecsTaskExecutionRole"
}