terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  name = "${var.environment}-${var.service_name}"
  tags = {
    project     = var.service_name
    environment = var.environment
    managedBy   = "terraform"
  }
}

# Deploys into an existing cluster/VPC -- a real platform provisions
# networking once, then deploys many services into it; a single starter
# template shouldn't also own VPC/cluster lifecycle. cluster_arn/vpc_id/
# subnet_ids/security_group_ids are required inputs, supplied by whoever
# deploys this (see README).
module "ecs" {
  source = "git::https://gitlab.com/gabaltech1/terraform-modules/terraform-aws-ecs.git?ref=v1.2.0"

  name        = local.name
  environment = var.environment

  cluster_arn        = var.cluster_arn
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  assign_public_ip   = true

  image = "${var.ecr_repository_url}:${var.image_tag}"
  port  = 3000

  log_retention_days = var.environment == "prod" ? 30 : 7

  tags = local.tags
}
