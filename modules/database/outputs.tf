output "instance_id" {
  value = aws_instance.database.id
}

output "private_ip" {
  value = aws_instance.database.private_ip
}

output "security_group_id" {
  value = aws_security_group.database.id
}

output "availability_zone" {
  value = aws_instance.database.availability_zone
}
