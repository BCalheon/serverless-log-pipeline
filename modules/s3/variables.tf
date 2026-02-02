variable "bucket_name" {
  description = "O nome do bucket que será criado"
  type        = string
}

variable "tags" {
  description = "Tags para o recurso (FinOps)"
  type        = map(string)
  default     = {}
}

variable "allow_force_destroy" {
  description = "Permite deletar o bucket mesmo com arquivos. Use apenas em Dev/Lab!"
  type        = bool
  default     = false # PADRÃO SEGURO
}