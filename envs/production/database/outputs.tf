output "database_instance_id" {
  value = module.database.instance_id
}

output "database_private_ip" {
  value = module.database.private_ip
}

output "database_security_group_id" {
  value = module.database.security_group_id
}

output "database_endpoint" {
  value = "${module.database.private_ip}:3306"
}

output "database_host_parameter" {
  value = aws_ssm_parameter.database_host.name
}

output "database_username_parameter" {
  value = aws_ssm_parameter.database_username.name
}

output "database_password_parameter" {
  value = aws_ssm_parameter.database_password.name
}
