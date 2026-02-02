terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }

  backend "s3" {
    bucket                      = "lab-devops-terraform-state-v1"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    
    # Voltando para a sintaxe de argumento (ignore o warning por enquanto)
    endpoint                    = "http://localhost:4566"
    
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}

# O restante do arquivo (provider "aws" e resource "aws_s3_bucket") permanece igual

# Configuração do Provider (O "Hack" para LocalStack)
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  s3_use_path_style           = true

  endpoints {
    s3             = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    route53        = "http://localhost:4566"
    rds            = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
  }
}

# Nosso primeiro recurso: Um Bucket S3 (Armazenamento)
module "s3_bucket_devops" {
  source      = "./modules/s3"
  bucket_name = "lab-devops-terraform-state-v1" # O MESMO NOME DO BACKEND
  
  # ATIVAMOS O RISCO SÓ AQUI, PORQUE É UM LAB
  allow_force_destroy = true 

  tags = {
    Environment = "Dev"
    Project     = "Infra-Lab"
    CostCenter  = "Marketing"
  }
}

# MÓDULO DE BANCO DE DADOS (RDS - Requer LocalStack Pro ou AWS Real)
# module "banco_sql" {
#   source      = "./modules/rds"
#   db_name     = "appdb"
#   db_username = "admin_user"
#   db_password = "SuperPassword123!"
# }

# output "endereco_do_banco" {
#   value = module.banco_sql.db_endpoint
# }


# Módulo DynamoDB (Substituto Cloud Native)
module "dynamodb_table" {
  source     = "./modules/dynamodb"
  table_name = "Tb_Logs_DevOps"
  
  tags = {
    Environment = "Lab"
    Project     = "NoSQL-Data"
  }
}