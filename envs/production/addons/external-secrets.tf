data "aws_iam_policy_document" "external_secrets_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::907259822627:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/C27D670D15D254A7152E47BB35A95CF8"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.ap-south-1.amazonaws.com/id/C27D670D15D254A7152E47BB35A95CF8:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.ap-south-1.amazonaws.com/id/C27D670D15D254A7152E47BB35A95CF8:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "cloudcart-production-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume.json

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "external_secrets_ssm" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:ap-south-1:907259822627:parameter/cloudcart/production/*"
    ]
  }
}

resource "aws_iam_policy" "external_secrets_ssm" {
  name   = "cloudcart-production-external-secrets-ssm-policy"
  policy = data.aws_iam_policy_document.external_secrets_ssm.json

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_ssm" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets_ssm.arn
}
