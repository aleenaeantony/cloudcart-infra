module "ecr" {
  source = "../../../modules/ecr"

  repository_names = [
    "api-gateway",
    "user-service",
    "product-service",
    "inventory-service",
    "order-service",
    "payment-service",
    "notification-service",
    "frontend"
  ]

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
