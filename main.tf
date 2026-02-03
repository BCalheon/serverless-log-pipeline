terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket                      = "lab-devops-terraform-state-v1"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://localhost:4566"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    iam      = "http://localhost:4566"
    sts      = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}

module "s3_bucket_infra" {
  source              = "./modules/s3"
  bucket_name         = "lab-devops-terraform-state-v1"
  allow_force_destroy = true 

  tags = {
    Environment = "Development"
    Project     = "Infrastructure-Automation"
  }
}

module "dynamodb_table" {
  source     = "./modules/dynamodb"
  table_name = "Tb_Logs_DevOps"
  
  tags = {
    Environment = "Development"
    Component   = "Data-Persistence"
  }
}

module "log_processor" {
  source        = "./modules/lambda"
  function_name = "LambdaLogProcessor"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "lab-devops-terraform-state-v1"

  lambda_function {
    lambda_function_arn = module.log_processor.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".log"
  }

  depends_on = [module.log_processor]
}