output "table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN del stream de DynamoDB (si está habilitado)"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "stream_label" {
  description = "Etiqueta del stream de DynamoDB (si está habilitado)"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null
}

output "table_tags" {
  description = "Tags aplicados a la tabla"
  value       = aws_dynamodb_table.this.tags_all
}

output "hash_key" {
  description = "Clave de partición de la tabla"
  value       = aws_dynamodb_table.this.hash_key
}

output "range_key" {
  description = "Clave de ordenamiento de la tabla"
  value       = aws_dynamodb_table.this.range_key
}

output "billing_mode" {
  description = "Modo de facturación de la tabla"
  value       = aws_dynamodb_table.this.billing_mode
}

output "global_secondary_indexes" {
  description = "Información de los índices secundarios globales"
  value = [
    for gsi in aws_dynamodb_table.this.global_secondary_index : {
      name      = gsi.name
      hash_key  = gsi.hash_key
      range_key = gsi.range_key
    }
  ]
}

output "table_class" {
  description = "Clase de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.table_class
}