terraform {
  backend "s3" {
    bucket         = "my-terraform-states"       # replace with your S3 bucket
    key            = "ecs/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"           # replace with your DynamoDB table
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# -----------------------------
# ECR Repositories
# -----------------------------
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"

  lifecycle_policy {
    policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images after 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": { "type": "expire" }
    }
  ]
}
EOF
  }
}

resource "aws_ecr_repository" "backend_repo" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"

  lifecycle_policy {
    policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images after 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": { "type": "expire" }
    }
  ]
}
EOF
  }
}

# -----------------------------
# ECS Cluster
# -----------------------------
resource "aws_ecs_cluster" "app_cluster" {
  name = "react-php-cluster"
}

# -----------------------------
# ECS Task Definitions
# -----------------------------
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

# -----------------------------
# ECS Services
# -----------------------------
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

# -----------------------------
# Variables
# -----------------------------
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "frontend_image" {
  description = "ECR image URI for React frontend"
  type        = string
}

variable "backend_image" {
  description = "ECR image URI for PHP backend"
  type        = string
}

variable "subnets" {
  description = "Subnets for ECS tasks"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# -----------------------------
# Outputs
# -----------------------------
output "frontend_repo_url" {
  value = aws_ecr_repository.frontend_repo.repository_url
}

output "backend_repo_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend_service.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend_service.name
}

output "cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}
