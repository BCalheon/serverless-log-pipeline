output "lambda_arn" {
  description = "O ARN da função Lambda criada"
  value       = aws_lambda_function.this.arn
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
}