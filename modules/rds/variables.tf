variable "db_name" {
  description = "Nome do banco de dados inicial"
  type        = string
}

variable "db_username" {
  description = "Usuário administrador"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
}