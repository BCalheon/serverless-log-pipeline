output "bucket_arn" {
  description = "Amazon Resource Name of the created bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  value = aws_s3_bucket.this.id
}