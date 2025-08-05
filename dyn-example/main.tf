module "game_scores" {
  source = "../modules/dynamodb"

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

  # Configuración para alto rendimiento
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD"
  
  #CAMBIOS PARA LOCALSTACK
  point_in_time_recovery = false             # No soportado
  deletion_protection    = false             # No necesario
  
  server_side_encryption = {
    enabled = false  # Evita problemas con KMS
  }
  # Cambios para localstack
  
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE" # Solo necesitamos las nuevas puntuaciones

  tags = {
    Environment = "production"
    Team        = "gaming"
    Project     = "leaderboard-service"
  }
}