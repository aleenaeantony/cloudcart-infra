variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_profile" {
  type    = string
  default = "ecommerce-web"
}

variable "vpc_id" {
  type    = string
  default = "vpc-00a830105ced76a0a"
}

variable "private_subnet_id" {
  type    = string
  default = "subnet-0502ca1d18a2d0382"
}

variable "eks_security_group_id" {
  type    = string
  default = "sg-07a8402a12a33280b"
}

variable "bastion_security_group_id" {
  type    = string
  default = "sg-083f525bac39723ba"
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
  type    = string
  default = "cloudcart"
}

variable "database_username" {
  type    = string
  default = "cloudcart_app"
}
