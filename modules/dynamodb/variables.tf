variable "table_name" {
  description = "db_dynamotest"
  type        = string
}

variable "tags" {
  description = "Tags de controle"
  type        = map(string)
  default     = {}
}