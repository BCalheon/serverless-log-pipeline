output "db_endpoint" {
  description = "O endereço de conexão (Host:Port)"
  value       = aws_db_instance.default.endpoint
}