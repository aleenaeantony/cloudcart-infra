variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "eks_security_group_id" {
  type = string
}

variable "bastion_security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "password_parameter_name" {
  type = string
}
