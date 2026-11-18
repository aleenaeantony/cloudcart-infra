variable "project_name" {
  type    = string
  default = "cloudcart-production"
}

variable "tags" {
  type    = map(string)
  default = {}
}
