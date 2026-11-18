variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.36"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "admin_principal_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}
