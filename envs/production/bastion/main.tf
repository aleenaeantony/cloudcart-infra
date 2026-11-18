data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "${path.module}/../eks/terraform.tfstate"
  }
}

data "aws_security_group" "vpc_endpoints" {
  filter {
    name   = "group-name"
    values = ["cloudcart-production-vpce-sg"]
  }

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

locals {
  ssm_endpoint_services = toset([
    "ssm",
    "ssmmessages",
    "ec2messages"
  ])
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = local.ssm_endpoint_services

  vpc_id              = data.terraform_remote_state.network.outputs.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids  = [data.aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudcart-production-${each.value}-endpoint"
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

module "bastion" {
  source = "../../../modules/bastion"

  name         = "cloudcart-production-bastion"
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  subnet_id    = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_vpc_endpoint.ssm]
}

resource "aws_vpc_security_group_ingress_rule" "eks_api_from_bastion" {
  security_group_id            = data.terraform_remote_state.eks.outputs.cluster_security_group_id
  referenced_security_group_id = module.bastion.security_group_id

  description = "Allow Kubernetes API access from production bastion"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}