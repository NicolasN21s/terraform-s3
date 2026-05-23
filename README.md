# terraform-s3

Módulo de Terraform para aprovisionar buckets S3 en AWS con controles de seguridad habilitados por defecto. Pensado para que cualquier equipo pueda consumirlo sin tener que reconfigurar cifrado, versionamiento ni políticas de acceso cada vez.

[![Terraform CI](https://github.com/NicolasN21s/terraform-s3/actions/workflows/ci.yml/badge.svg)](https://github.com/NicolasN21s/terraform-s3/actions/workflows/ci.yml)

---

## Motivación

Cuando varios equipos crean buckets S3 de forma independiente, es común que se salten configuraciones críticas de seguridad: acceso público abierto, objetos sin cifrar, sin versionamiento. Este módulo estandariza esos controles para que no dependan de quien lo implemente.

---

## Qué incluye el módulo

- Bloqueo total de acceso público (las 4 flags de Block Public Access)
- Versionamiento habilitado desde el inicio
- Cifrado en reposo con AES256 por defecto, o con llave KMS propia si se provee
- Política de bucket que rechaza uploads sin cifrado y conexiones sin TLS
- Regla de lifecycle para expirar versiones antiguas (90 días por defecto, configurable)

---

## Estructura del repositorio

```
terraform-s3/
├── .github/
│   └── workflows/
│       └── ci.yml              # Pipeline de validación automática
├── modules/
│   └── s3/
│       ├── main.tf             # Recursos del bucket y sus configuraciones
│       ├── variables.tf        # Variables de entrada con validaciones
│       ├── outputs.tf          # Valores exportados por el módulo
│       └── versions.tf         # Versiones requeridas de Terraform y providers
├── main.tf                     # Ejemplo de consumo del módulo
├── variables.tf
├── terraform.tfvars.example    # Plantilla para variables locales
├── .gitignore
└── README.md
```

---

## Uso

### Requisitos previos

- Terraform >= 1.5.0
- AWS CLI configurado con credenciales válidas (solo para `apply`)
- AWS provider >= 5.0

### Clonar e inicializar

```bash
git clone https://github.com/NicolasN21s/terraform-s3.git
cd terraform-s3

cp terraform.tfvars.example terraform.tfvars
# Ajustar bucket_name y environment según el entorno
```

### Planificar y aplicar

```bash
terraform init
terraform plan
terraform apply
```

### Uso mínimo como módulo

```hcl
module "bucket_app" {
  source = "./modules/s3"

  bucket_name = "mi-app-uploads-dev"
  environment = "dev"
}
```

### Uso con llave KMS propia y retención reducida

```hcl
module "bucket_app" {
  source = "./modules/s3"

  bucket_name = "mi-app-uploads-prod"
  environment = "prod"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"

  noncurrent_version_expiration_days = 30

  tags = {
    Team       = "backend"
    CostCenter = "cc-42"
  }
}
```

---

## Variables

| Nombre | Tipo | Obligatorio | Valor por defecto | Descripción |
|--------|------|:-----------:|:-----------------:|-------------|
| `bucket_name` | `string` | sí | — | Nombre del bucket. Debe ser único globalmente en AWS. |
| `environment` | `string` | sí | — | Entorno destino. Valores aceptados: `dev`, `staging`, `prod`. |
| `kms_key_arn` | `string` | no | `null` | ARN de llave KMS. Si no se provee, se usa AES256. |
| `enable_lifecycle` | `bool` | no | `true` | Activa la regla de expiración de versiones antiguas. |
| `noncurrent_version_expiration_days` | `number` | no | `90` | Días que se conservan las versiones no actuales antes de eliminarlas. |
| `tags` | `map(string)` | no | `{}` | Tags adicionales que se fusionan con los del módulo. |

## Outputs

| Nombre | Descripción |
|--------|-------------|
| `bucket_id` | Nombre del bucket creado |
| `bucket_arn` | ARN del bucket |
| `bucket_region` | Región donde fue creado |
| `bucket_domain_name` | Endpoint path-style del bucket |
| `versioning_status` | Estado actual del versionamiento |

---

## Pipeline de CI

El archivo `.github/workflows/ci.yml` se ejecuta automáticamente en cada Pull Request hacia `main`. No requiere credenciales AWS reales; el job de `plan` corre con variables de entorno ficticias y el flag `-refresh=false` para evitar llamadas a la API.

Los jobs corren en este orden:

```
fmt → validate → tfsec  ─┬─ plan
                checkov  ─┘
```

| Job | Herramienta | Propósito |
|-----|-------------|-----------|
| `fmt` | `terraform fmt -check` | Verifica que el código siga el formato estándar de Terraform |
| `validate` | `terraform validate` | Confirma que la sintaxis y referencias internas sean correctas |
| `security` | tfsec | Detecta configuraciones inseguras o que no siguen buenas prácticas |
| `checkov` | Checkov | Evalúa compliance contra frameworks como CIS y PCI-DSS |
| `plan` | `terraform plan -refresh=false` | Genera el plan de ejecución sin conectarse a AWS |

---

## Decisiones de diseño

**¿Por qué AES256 como default y no KMS?** KMS tiene costo por cada operación de cifrado. AES256 (SSE-S3) no genera costo adicional y cubre la mayoría de casos. Si el equipo necesita auditoría de uso de llaves o rotación controlada, se pasa el `kms_key_arn`.

**¿Por qué la política de bucket rechaza uploads sin TLS?** Un bucket puede estar bien configurado pero si alguien sube objetos por HTTP, los datos viajan en claro. La política de `aws:SecureTransport` cierra ese vector sin costo ni complejidad adicional.

**¿Por qué el lifecycle está habilitado por defecto?** Sin él, las versiones antiguas acumulan almacenamiento indefinidamente. 90 días es un valor razonable que da margen para recuperar objetos sin generar costos innecesarios.

---

## Convenciones

- Nunca hardcodear ARNs ni credenciales en los archivos `.tf`. Usar variables.
- El archivo `terraform.tfvars` está en `.gitignore`. Usar `terraform.tfvars.example` como referencia.
- Ejecutar `terraform fmt` antes de cualquier commit.

---

## Licencia

MIT
