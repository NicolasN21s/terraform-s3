# Implementación de ejemplo – consume el módulo s3


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
  }

  # Descomenta y configura para usar un backend remoto en equipo:
  # backend "s3" {
  #   bucket  = "mi-terraform-state"
  #   key     = "platform/s3-example/terraform.tfstate"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "platform-s3-example"
      ManagedBy = "terraform"
    }
  }
}


# Módulo – bucket principal de la aplicación

module "app_bucket" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
  environment = var.environment
  kms_key_arn = var.kms_key_arn

  enable_lifecycle                   = true
  noncurrent_version_expiration_days = 90

  tags = {
    Team    = "platform-engineering"
    CostCenter = "infra-001"
  }
}


# Outputs de la implementación raíz

output "bucket_id" {
  description = "Nombre del bucket creado."
  value       = module.app_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN del bucket creado."
  value       = module.app_bucket.bucket_arn
}

output "bucket_region" {
  description = "Región donde fue creado el bucket."
  value       = module.app_bucket.bucket_region
}
