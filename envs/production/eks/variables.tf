variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type    = string
  default = "cloudcart-production-eks-cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.36"
}
