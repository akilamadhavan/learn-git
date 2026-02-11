variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "frontend_image" {
  description = "Docker image for React frontend"
  type        = string
}

variable "backend_image" {
  description = "Docker image for PHP backend"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}
