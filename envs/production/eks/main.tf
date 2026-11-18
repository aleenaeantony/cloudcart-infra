data "aws_caller_identity" "current" {}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "${path.module}/../iam/terraform.tfstate"
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  cluster_role_arn = data.terraform_remote_state.iam.outputs.cluster_role_arn
  node_role_arn    = data.terraform_remote_state.iam.outputs.node_role_arn

  admin_principal_arn = data.aws_caller_identity.current.arn

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

data "aws_eks_cluster" "current" {
  name = "cloudcart-production-eks-cluster"
}
