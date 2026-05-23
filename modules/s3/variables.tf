# Variables del módulo S3


variable "bucket_name" {
  description = "Nombre global único del bucket S3."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "El nombre debe tener entre 3 y 63 caracteres, solo minúsculas, números y guiones, sin empezar ni terminar en guion."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev | staging | prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El valor de environment debe ser 'dev', 'staging' o 'prod'."
  }
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para cifrado. Si es null se usa AES256 (SSE-S3)."
  type        = string
  default     = null
}

variable "enable_lifecycle" {
  description = "Habilita regla de lifecycle para expirar versiones no actuales."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Días antes de expirar versiones no actuales de objetos."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Mapa de etiquetas adicionales que se fusionan con las del módulo."
  type        = map(string)
  default     = {}
}
