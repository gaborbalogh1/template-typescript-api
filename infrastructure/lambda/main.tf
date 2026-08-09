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

# Deploys a placeholder on first apply, same as every other Lambda in this
# ecosystem (see e.g. aws_infrastructure/pulumi/idp/src/lambda.ts) -- the
# real deployment package is pushed separately by the CI workflow via
# `aws lambda update-function-code`, not by Terraform. Terraform owns the
# function's existence/config, not its code.
module "lambda" {
  source = "git::https://gitlab.com/gabaltech1/terraform-modules/terraform-aws-serverless.git?ref=v1.1.0"

  name    = local.name
  handler = "dist/lambda.handler"
  runtime = "nodejs22.x"

  enable_function_url = true
  # No custom domain by default -- a starter template shouldn't assume a
  # Route53 zone exists for an arbitrary customer's account. Point
  # enable_cloudfront/domain/hosted_zone_id at a real zone once deployed.
  enable_cloudfront = false

  environment_variables = {
    SERVICE_NAME = var.service_name
    NODE_ENV     = var.environment == "prod" ? "production" : var.environment
  }

  log_retention_days = var.environment == "prod" ? 30 : 7

  tags = local.tags
}
