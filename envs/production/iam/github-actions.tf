resource "aws_iam_role" "github_actions" {
  name = "cloudcart-production-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = "arn:aws:iam::907259822627:oidc-provider/token.actions.githubusercontent.com"
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:aleenaeantony@*/cloudcart-platform@*:environment:prod"
        }
      }
    }]
  })

  tags = {
    Project     = "CloudCart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "github_actions_ecr_push" {
  name        = "cloudcart-production-github-actions-ecr-push"
  description = "Allow CloudCart GitHub Actions to push images to CloudCart ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          "arn:aws:ecr:ap-south-1:907259822627:repository/api-gateway",
          "arn:aws:ecr:ap-south-1:907259822627:repository/user-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/product-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/inventory-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/order-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/payment-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/notification-service",
          "arn:aws:ecr:ap-south-1:907259822627:repository/frontend"
        ]
      }
    ]
  })

  tags = {
    Project     = "CloudCart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}
