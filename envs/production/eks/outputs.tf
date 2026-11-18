output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_group_name" {
  value = module.eks.node_group_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}


output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = data.aws_eks_cluster.current.vpc_config[0].cluster_security_group_id
}
