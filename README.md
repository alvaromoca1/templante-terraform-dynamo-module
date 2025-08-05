# 🚀 Módulo Terraform para DynamoDB

Un módulo de Terraform súper flexible y reutilizable para crear tablas de DynamoDB con todas las características que necesitas. Compatible tanto con AWS real como con LocalStack para desarrollo local.

## 📋 Índice

- [🎯 Características](#-características)
- [📁 Estructura del Proyecto](#-estructura-del-proyecto)
- [🛠️ Instalación](#️-instalación)
- [🔧 Configuración](#-configuración)
  - [AWS Production](#aws-production)
  - [LocalStack Development](#localstack-development)
- [📖 Uso Básico](#-uso-básico)
- [📚 Ejemplos](#-ejemplos)
- [🔍 Variables](#-variables)
- [📤 Outputs](#-outputs)
- [🧪 Testing con LocalStack](#-testing-con-localstack)
- [⚠️ Mejores Prácticas](#️-mejores-prácticas)
- [🤝 Contribuir](#-contribuir)

## 🎯 Características

- ✅ **Tabla básica** con hash key y range key opcional
- ✅ **Global Secondary Indexes (GSI)** con configuración flexible
- ✅ **Local Secondary Indexes (LSI)** para queries eficientes
- ✅ **TTL (Time To Live)** para expiración automática de datos
- ✅ **DynamoDB Streams** para triggers y replicación
- ✅ **Point-in-time Recovery** para backups automáticos
- ✅ **Server-side Encryption** con KMS
- ✅ **Billing modes**: PAY_PER_REQUEST y PROVISIONED
- ✅ **Table classes**: STANDARD y STANDARD_INFREQUENT_ACCESS
- ✅ **Validaciones** para prevenir errores comunes
- ✅ **Tags automáticos** y personalizables
- ✅ **Compatible con LocalStack** para desarrollo local

## 📁 Estructura del Proyecto

```
proyecto-dynamodb/
├── modules/
│   └── dynamodb/
│       ├── main.tf          # Recurso DynamoDB
│       ├── variables.tf     # Variables de entrada
│       ├── outputs.tf       # Valores de salida
│       └── versions.tf      # Versiones requeridas
├── dyn-example/
│   ├── main.tf/        # Ejemplo tabla básica
├── main.tf                  # Configuración principal
├── variables.tf             # Variables globales
└── README.md               # Este archivo
```

## 🛠️ Instalación

1. **Clona o descarga** los archivos del módulo
2. **Copia la carpeta** `modules/dynamodb` a tu proyecto
3. **Instala Terraform** >= 1.0
4. **Configura el provider** según tu entorno

```bash
# Inicializar Terraform
terraform init

# Verificar la configuración
terraform plan

# Aplicar los cambios
terraform apply
```

## 🔧 Configuración

### AWS Production

Para usar en producción con AWS real:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Usa tus credenciales normales de AWS
}
```

### LocalStack Development

Para desarrollo local con LocalStack, necesitas estos cambios específicos:

```hcl
provider "aws" {
  region = "us-east-1"
  
  # 🔧 CAMBIOS SOLO PARA LOCALSTACK
  access_key                  = "test"                      # Cambios solo para LocalStack
  secret_key                  = "test"                      # Cambios solo para LocalStack
  skip_credentials_validation = true                        # Cambios solo para LocalStack
  skip_metadata_api_check     = true                        # Cambios solo para LocalStack
  skip_requesting_account_id  = true                        # Cambios solo para LocalStack
  
  # Cambios para LocalStack
  endpoints {
    dynamodb = "http://localhost:4566"                 # Cambios para LocalStack
  }
}
```

**⚠️ IMPORTANTE**: Estos cambios son **SOLO para LocalStack**. Nunca uses estas configuraciones en producción.

## 📖 Uso Básico

### Tabla Simple (Mínima configuración)

```hcl
module "users_table" {
  source = "./modules/dynamodb"

  table_name = "users"
  hash_key   = "user_id"

  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]
}
```

### Tabla para LocalStack

```hcl
module "users_table_local" {
  source = "./modules/dynamodb"

  table_name   = "users"
  hash_key     = "user_id"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]

  # 🔧 CAMBIOS PARA LOCALSTACK
  point_in_time_recovery = false                           # No soportado
  deletion_protection    = false                           # No necesario
  
  server_side_encryption = {
    enabled = false                                         # Evita problemas con KMS
  }

  tags = {
    Environment = "local"
    LocalStack  = "true"
  }
}
```

## 📚 Ejemplos

### Ejemplo 1: Tabla de Usuarios (Simple)

```hcl
module "users_table" {
  source = "./modules/dynamodb"

  table_name   = "users"
  hash_key     = "user_id"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]

  tags = {
    Environment = "production"
    Team        = "backend"
    Project     = "user-management"
  }
}
```

### Ejemplo 2: Tabla de Órdenes (Compleja)

```hcl
module "orders_table" {
  source = "./modules/dynamodb"

  table_name     = "orders"
  hash_key       = "order_id"
  range_key      = "created_at"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 5

  attributes = [
    {
      name = "order_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    },
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    },
    {
      name = "total_amount"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "user-orders-index"
      hash_key        = "user_id"
      range_key       = "created_at"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    },
    {
      name            = "status-index"
      hash_key        = "status"
      projection_type = "INCLUDE"
      non_key_attributes = ["order_id", "total_amount"]
      read_capacity   = 5
      write_capacity  = 5
    }
  ]

  local_secondary_indexes = [
    {
      name            = "amount-index"
      range_key       = "total_amount"
      projection_type = "KEYS_ONLY"
    }
  ]

  # Configuraciones avanzadas
  ttl_enabled           = true
  ttl_attribute_name    = "expires_at"
  point_in_time_recovery = true
  stream_enabled        = true
  stream_view_type      = "NEW_AND_OLD_IMAGES"
  deletion_protection   = true

  server_side_encryption = {
    enabled = true
  }

  tags = {
    Environment = "production"
    Team        = "ecommerce"
    Project     = "order-management"
    CostCenter  = "engineering"
  }
}
```

### Ejemplo 3: Gaming Leaderboard

```hcl
module "game_scores" {
  source = "./modules/dynamodb"

  table_name = "game-leaderboard"
  hash_key   = "game_id"
  range_key  = "score"

  attributes = [
    {
      name = "game_id"
      type = "S"
    },
    {
      name = "score"
      type = "N"
    },
    {
      name = "player_id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "player-scores"
      hash_key        = "player_id"
      range_key       = "timestamp"
      projection_type = "ALL"
    }
  ]

  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD"
  
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  tags = {
    Environment = "production"
    Team        = "gaming"
    Project     = "leaderboard-service"
  }
}
```

## 🔍 Variables

### Variables Requeridas

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `table_name` | `string` | Nombre de la tabla DynamoDB |
| `hash_key` | `string` | Clave de partición (hash key) |
| `attributes` | `list(object)` | Lista de atributos con name y type |

### Variables Opcionales

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `billing_mode` | `string` | `"PAY_PER_REQUEST"` | Modo de facturación |
| `range_key` | `string` | `null` | Clave de ordenamiento |
| `read_capacity` | `number` | `5` | Capacidad de lectura (PROVISIONED) |
| `write_capacity` | `number` | `5` | Capacidad de escritura (PROVISIONED) |
| `global_secondary_indexes` | `list(object)` | `[]` | Índices secundarios globales |
| `local_secondary_indexes` | `list(object)` | `[]` | Índices secundarios locales |
| `ttl_enabled` | `bool` | `false` | Habilitar TTL |
| `ttl_attribute_name` | `string` | `"ttl"` | Nombre del atributo TTL |
| `point_in_time_recovery` | `bool` | `true` | Recuperación point-in-time |
| `stream_enabled` | `bool` | `false` | Habilitar DynamoDB Streams |
| `stream_view_type` | `string` | `"NEW_AND_OLD_IMAGES"` | Tipo de vista del stream |
| `server_side_encryption` | `object` | `{enabled = true}` | Configuración de cifrado |
| `table_class` | `string` | `"STANDARD"` | Clase de tabla |
| `deletion_protection` | `bool` | `false` | Protección contra eliminación |
| `tags` | `map(string)` | `{}` | Tags personalizados |

### Tipos de Atributos

- `"S"` - String
- `"N"` - Number  
- `"B"` - Binary

### Modos de Facturación

- `"PAY_PER_REQUEST"` - Pago por solicitud (recomendado)
- `"PROVISIONED"` - Capacidad aprovisionada

### Tipos de Proyección (GSI/LSI)

- `"ALL"` - Todos los atributos
- `"KEYS_ONLY"` - Solo claves
- `"INCLUDE"` - Atributos específicos

## 📤 Outputs

| Output | Descripción |
|--------|-------------|
| `table_name` | Nombre de la tabla |
| `table_arn` | ARN de la tabla |
| `table_id` | ID de la tabla |
| `stream_arn` | ARN del stream (si está habilitado) |
| `stream_label` | Etiqueta del stream |
| `hash_key` | Clave de partición |
| `range_key` | Clave de ordenamiento |
| `billing_mode` | Modo de facturación |
| `global_secondary_indexes` | Info de GSI |
| `table_class` | Clase de la tabla |

## 🧪 Testing con LocalStack

### 1. Iniciar LocalStack

```bash
# Con Docker
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack

# O con docker-compose
version: '3.8'
services:
  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=dynamodb
      - DEBUG=1
```

### 2. Usar el Script Helper

```bash
# Hacer ejecutable
chmod +x scripts/localstack-setup.sh

# Verificar LocalStack
./scripts/localstack-setup.sh check

# Configurar AWS CLI
./scripts/localstack-setup.sh setup

# Ejecutar Terraform
./scripts/localstack-setup.sh terraform init
./scripts/localstack-setup.sh terraform apply

# Listar tablas
./scripts/localstack-setup.sh list

# Describir tabla
./scripts/localstack-setup.sh describe test-users

# Insertar datos de prueba
./scripts/localstack-setup.sh test-data test-users

# Limpiar todo
./scripts/localstack-setup.sh cleanup
```

### 3. Verificar Manualmente

```bash
# Health check
curl http://localhost:4566/health

# Listar tablas con AWS CLI
aws dynamodb list-tables \
  --endpoint-url http://localhost:4566 \
  --profile localstack

# Describir tabla
aws dynamodb describe-table \
  --table-name users \
  --endpoint-url http://localhost:4566 \
  --profile localstack
```

## ⚠️ Mejores Prácticas

### Desarrollo Local (LocalStack)

```hcl
# ✅ Configuración recomendada para LocalStack
module "local_table" {
  source = "./modules/dynamodb"
  
  table_name   = "test-table"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"          # Más simple
  
  # Desactivar características no soportadas
  point_in_time_recovery = false            # No soportado
  deletion_protection    = false            # No necesario
  
  server_side_encryption = {
    enabled = false                          # Evita problemas
  }
  
  tags = {
    Environment = "local"
    LocalStack  = "true"
  }
}
```

### Producción (AWS)

```hcl
# ✅ Configuración recomendada para producción
module "prod_table" {
  source = "./modules/dynamodb"
  
  table_name   = "prod-users"
  hash_key     = "user_id"
  billing_mode = "PAY_PER_REQUEST"
  
  # Características de producción
  point_in_time_recovery = true             # Backup automático
  deletion_protection    = true             # Protección
  
  server_side_encryption = {
    enabled     = true
    kms_key_arn = "arn:aws:kms:..."         # KMS personalizado
  }
  
  tags = {
    Environment = "production"
    Team        = "backend"
    CostCenter  = "engineering"
  }
}
```

### Naming Conventions

```hcl
# ✅ Buenos nombres
table_name = "users"                        # Simple y claro
table_name = "user-sessions"                # Con guión
table_name = "game-leaderboard"             # Descriptivo

# ❌ Evitar
table_name = "MyAwesomeTable"               # CamelCase
table_name = "tbl_users_data_v2"            # Demasiado complejo
```

### GSI Design

```hcl
# ✅ GSI bien diseñado
global_secondary_indexes = [
  {
    name            = "user-orders-index"   # Nombre descriptivo
    hash_key        = "user_id"
    range_key       = "created_at"         # Para sorting
    projection_type = "ALL"                # O KEYS_ONLY si no necesitas todos los datos
  }
]
```

### Tags Strategy

```hcl
# ✅ Tags útiles
tags = {
  Environment = "production"                # Obligatorio
  Team        = "backend"                   # Responsable
  Project     = "user-management"           # Proyecto
  CostCenter  = "engineering"               # Para billing
  ManagedBy   = "terraform"                 # Automatizado
}
```

## 🤝 Contribuir

1. **Fork** el repositorio
2. **Crea** una rama para tu feature (`git checkout -b feature/amazing-feature`)
3. **Commit** tus cambios (`git commit -m 'Add amazing feature'`)
4. **Push** a la rama (`git push origin feature/amazing-feature`)
5. **Abre** un Pull Request

### Desarrollo

```bash
# Instalar pre-commit hooks
pre-commit install

# Formatear código
terraform fmt -recursive

# Validar sintaxis  
terraform validate

# Ejecutar tests
terraform plan
```

---

## 📞 Soporte

¿Tienes problemas o preguntas?

- 🐛 **Issues**: Reporta bugs en GitHub Issues
- 💬 **Discusiones**: Pregunta en GitHub Discussions  
- 📚 **Docs**: Revisa la documentación de Terraform y AWS

---

**¡Hecho con ❤️ para la comunidad de DevOps!**

> Recuerda: Los cambios específicos de LocalStack están claramente marcados y **nunca** deben usarse en producción.