output "instance_id" {
  value = aws_instance.bastion.id
}

output "private_ip" {
  value = aws_instance.bastion.private_ip
}

output "iam_role_arn" {
  value = aws_iam_role.bastion.arn
}

output "security_group_id" {
  value = aws_security_group.bastion.id
}
