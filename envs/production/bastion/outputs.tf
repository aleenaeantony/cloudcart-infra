output "instance_id" {
  value = module.bastion.instance_id
}

output "private_ip" {
  value = module.bastion.private_ip
}

output "iam_role_arn" {
  value = module.bastion.iam_role_arn
}

output "security_group_id" {
  description = "Bastion security group ID"
  value       = module.bastion.security_group_id
}
