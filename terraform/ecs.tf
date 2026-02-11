resource "aws_ecs_cluster" "app_cluster" {
  name = "react-php-cluster"
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    portMappings = [{ containerPort = 80 }]
  }])
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    portMappings = [{ containerPort = 80 }]
  }])
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.sg_id]
  }
}

resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.sg_id]
  }
}
