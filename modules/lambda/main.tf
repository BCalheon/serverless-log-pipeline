# Compacta o código-fonte Python em um arquivo .zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../src/lambda_function.py"
  output_path = "${path.module}/../../src/lambda_function.zip"
}

# Criar a Role (identidade) para a Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "role_${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# A definição da função Lambda propriamente dita
resource "aws_lambda_function" "this" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler" # arquivo.funcao

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"

  tags = {
    Name = var.function_name
  }
}

# Permite que o S3 (Principal) invoque esta Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  
  # O ARN do bucket que tem permissão de "ligar" para a Lambda
  source_arn    = "arn:aws:s3:::lab-devops-terraform-state-v1"
}

# 1. Define a política de permissão (O que ela pode fazer)
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_write_policy"
  description = "Permite que a lambda escreva no DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        # Permite em qualquer tabela neste lab
        Resource = "*" 
      }
    ]
  })
}

# 2. Anexa a política à Role da Lambda (Quem recebe o poder)
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Política para permitir que a Lambda apague objetos no S3
resource "aws_iam_policy" "lambda_s3_delete_policy" {
  name        = "lambda_s3_delete_policy"
  description = "Permite que a lambda elimine objetos processados no S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::lab-devops-terraform-state-v1/*"
      }
    ]
  })
}

# Anexar a nova política à Role da Lambda
resource "aws_iam_role_policy_attachment" "lambda_s3_delete_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3_delete_policy.arn
}