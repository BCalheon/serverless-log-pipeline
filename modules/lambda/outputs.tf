output "lambda_arn" {
  description = "The ARN of the created lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
}