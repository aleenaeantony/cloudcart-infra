data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "${path.module}/../eks/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  oidc_issuer_hostpath = trimprefix(
    data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
    "https://"
  )
}

resource "aws_iam_role" "ebs_csi" {
  name = "cloudcart-production-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi
  ]
}

data "aws_iam_policy_document" "aws_lbc_assume" {
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
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = "cloudcart-production-aws-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc_assume.json

  tags = {
    Project     = "cloudcart"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  role       = aws_iam_role.aws_lbc.name
  policy_arn = "arn:aws:iam::907259822627:policy/cloudcart-production-aws-load-balancer-controller-policy"
}

output "aws_lbc_role_arn" {
  value = aws_iam_role.aws_lbc.arn
}
