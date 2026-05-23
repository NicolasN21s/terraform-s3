# Outputs del módulo S3

output "bucket_id" {
  description = "ID (nombre) del bucket S3 creado."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket S3 creado."
  value       = aws_s3_bucket.this.arn
}

output "bucket_region" {
  description = "Región AWS donde se creó el bucket."
  value       = aws_s3_bucket.this.region
}

output "bucket_domain_name" {
  description = "Nombre de dominio del bucket (path-style)."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "versioning_status" {
  description = "Estado del versionamiento del bucket."
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}
