resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  
  # Configurações Críticas para Lab (LocalStack)
  skip_final_snapshot  = true
  publicly_accessible  = true 
  
  tags = {
    Name        = "Lab-RDS"
    Environment = "Dev"
  }
}