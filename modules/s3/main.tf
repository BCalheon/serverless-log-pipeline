resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.allow_force_destroy # USA A VARIÁVEL DE SEGURANÇA
  tags          = var.tags
}