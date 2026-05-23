# Variables – implementación raíz


variable "aws_region" {
  description = "Región AWS donde se desplegará el bucket."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre global único del bucket S3."
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev | staging | prod)."
  type        = string
  default     = "dev"
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para cifrado. Opcional; si se omite se usa AES256."
  type        = string
  default     = null
}
