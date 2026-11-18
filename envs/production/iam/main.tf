provider "aws" {
  region = var.aws_region
}

module "iam" {
  source = "../../../modules/iam"

  project_name = var.project_name

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
