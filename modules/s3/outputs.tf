output "bucket_arn" {
  description = "O ARN (Amazon Resource Name) do bucket criado"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  value = aws_s3_bucket.this.id
}