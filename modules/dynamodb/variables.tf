variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "tags" {
  description = "Tags de controle"
  type        = map(string)
  default     = {}
}