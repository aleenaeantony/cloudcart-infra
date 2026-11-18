resource "random_password" "database" {
  length           = 32
  special          = true
  override_special = "!#$%&()*+,-.:=?@[]^_{|}~"
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/cloudcart/production/mysql-ec2/password"
  description = "CloudCart EC2 MySQL application password"
  type        = "SecureString"
  value       = random_password.database.result
  overwrite   = true

  tags = {
    Project = "CloudCart"
  }
}

resource "aws_ssm_parameter" "database_username" {
  name  = "/cloudcart/production/mysql-ec2/username"
  type  = "String"
  value = var.database_username

  tags = {
    Project = "CloudCart"
  }
}

resource "aws_ssm_parameter" "database_name" {
  name  = "/cloudcart/production/mysql-ec2/database"
  type  = "String"
  value = var.database_name

  tags = {
    Project = "CloudCart"
  }
}

module "database" {
  source = "../../../modules/database"

  name                      = "cloudcart-production-mysql-ec2"
  aws_region                = var.aws_region
  subnet_id                 = var.private_subnet_id
  vpc_id                    = var.vpc_id
  eks_security_group_id     = var.eks_security_group_id
  bastion_security_group_id = var.bastion_security_group_id
  instance_type             = var.instance_type
  root_volume_size          = var.root_volume_size
  database_name             = var.database_name
  database_username         = var.database_username
  password_parameter_name   = aws_ssm_parameter.database_password.name
}

resource "aws_ssm_parameter" "database_host" {
  name        = "/cloudcart/production/mysql-ec2/host"
  description = "CloudCart EC2 MySQL private IP"
  type        = "String"
  value       = module.database.private_ip

  tags = {
    Project = "CloudCart"
  }
}

resource "aws_ssm_parameter" "database_port" {
  name  = "/cloudcart/production/mysql-ec2/port"
  type  = "String"
  value = "3306"

  tags = {
    Project = "CloudCart"
  }
}
