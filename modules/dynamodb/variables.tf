variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "billing_mode" {
  description = "Modo de facturación: PAY_PER_REQUEST o PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode debe ser PAY_PER_REQUEST o PROVISIONED."
  }
}

variable "hash_key" {
  description = "Clave de partición (hash key) de la tabla"
  type        = string
}

variable "range_key" {
  description = "Clave de ordenamiento (range key) - opcional"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Lista de atributos para la tabla"
  type = list(object({
    name = string
    type = string # S, N, o B (String, Number, Binary)
  }))
}

variable "read_capacity" {
  description = "Capacidad de lectura (solo para PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacidad de escritura (solo para PROVISIONED)"
  type        = number
  default     = 5
}

variable "global_secondary_indexes" {
  description = "Índices secundarios globales"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL") # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number, 5)
    write_capacity     = optional(number, 5)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Índices secundarios locales"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "ttl_enabled" {
  description = "Habilitar TTL (Time To Live)"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nombre del atributo TTL"
  type        = string
  default     = "ttl"
}

variable "point_in_time_recovery" {
  description = "Habilitar recuperación point-in-time"
  type        = bool
  default     = true
}

variable "server_side_encryption" {
  description = "Configuración de cifrado del lado del servidor"
  type = object({
    enabled     = optional(bool, true)
    kms_key_arn = optional(string, null)
  })
  default = {
    enabled = true
  }
}

variable "stream_enabled" {
  description = "Habilitar DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Tipo de vista del stream"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
  
  validation {
    condition = contains([
      "KEYS_ONLY",
      "NEW_IMAGE", 
      "OLD_IMAGE",
      "NEW_AND_OLD_IMAGES"
    ], var.stream_view_type)
    error_message = "stream_view_type debe ser uno de: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "tags" {
  description = "Tags para aplicar a la tabla"
  type        = map(string)
  default     = {}
}

variable "table_class" {
  description = "Clase de tabla: STANDARD o STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"
  
  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class debe ser STANDARD o STANDARD_INFREQUENT_ACCESS."
  }
}

variable "deletion_protection" {
  description = "Protección contra eliminación accidental"
  type        = bool
  default     = false
}