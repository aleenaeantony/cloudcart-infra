data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name}-sg"
  description = "Private MySQL access from CloudCart EKS and bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  ingress {
    description     = "MySQL from bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.name}-sg"
    Project   = "CloudCart"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "database" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.database.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "database_password" {
  name = "${var.name}-read-db-password"
  role = aws_iam_role.database.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ssm:GetParameter"]
      Resource = "arn:aws:ssm:${var.aws_region}:*:parameter${var.password_parameter_name}"
    }]
  })
}

resource "aws_iam_instance_profile" "database" {
  name = "${var.name}-profile"
  role = aws_iam_role.database.name
}

locals {
  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    exec > >(tee -a /var/log/cloud-init-database.log) 2>&1

    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y curl wget gnupg awscli snapd

    snap install amazon-ssm-agent --classic || true
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

    install -d -m 0755 /usr/share/keyrings
    wget -qO /usr/share/keyrings/mysql-apt-config.asc https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

    echo "deb [signed-by=/usr/share/keyrings/mysql-apt-config.asc] http://repo.mysql.com/apt/ubuntu noble mysql-8.4-lts" \
      > /etc/apt/sources.list.d/mysql-8.4.list

    apt-get update
    apt-get install -y mysql-server

    systemctl enable mysql
    systemctl start mysql

    DB_PASSWORD=$(aws ssm get-parameter \
      --name '${var.password_parameter_name}' \
      --with-decryption \
      --region '${var.aws_region}' \
      --query 'Parameter.Value' \
      --output text)

    mysql -uroot <<SQL
    CREATE DATABASE IF NOT EXISTS \`${var.database_name}\`;
    CREATE USER IF NOT EXISTS '${var.database_username}'@'%' IDENTIFIED BY '$DB_PASSWORD';
    ALTER USER '${var.database_username}'@'%' IDENTIFIED BY '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON \`${var.database_name}\`.* TO '${var.database_username}'@'%';
    FLUSH PRIVILEGES;
    SQL

    sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    systemctl restart mysql

    mysql -uroot -e "SELECT VERSION();"
    echo "CLOUDCART_MYSQL_BOOTSTRAP_COMPLETED"
  USERDATA
}

resource "aws_instance" "database" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.database.id]
  iam_instance_profile        = aws_iam_instance_profile.database.name
  associate_public_ip_address = false
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false

    tags = {
      Name = "${var.name}-data"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name      = var.name
    Project   = "CloudCart"
    ManagedBy = "Terraform"
    Backup    = "cloudcart-mysql"
  }

  depends_on = [
    aws_iam_role_policy.database_password,
    aws_iam_role_policy_attachment.ssm
  ]
}
