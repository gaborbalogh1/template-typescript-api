variable "service_name" {
  description = "Name of the service. Used as a prefix for all created resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be dev, test, or prod."
  }
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

variable "image_tag" {
  description = "Container image tag to deploy."
  type        = string
  default     = "latest"
}

variable "ecr_repository_url" {
  description = "ECR repository URL the container image lives in."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of an existing ECS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the ECS tasks."
  type        = list(string)
}
