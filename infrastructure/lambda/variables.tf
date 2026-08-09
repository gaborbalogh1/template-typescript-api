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
