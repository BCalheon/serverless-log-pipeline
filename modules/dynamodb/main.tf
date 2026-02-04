resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST" # Serverless (Custo zero se parado)
  hash_key       = "LockID"          # Chave primária obrigatória

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}