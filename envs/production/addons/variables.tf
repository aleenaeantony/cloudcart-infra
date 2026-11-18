variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type    = string
  default = "cloudcart-production-eks-cluster"
}

variable "grafana_cloud_prometheus_url" {
  type        = string
  description = "Grafana Cloud Prometheus remote-write URL"
  default     = ""
}

variable "grafana_cloud_username" {
  type        = string
  description = "Grafana Cloud Prometheus username"
  default     = ""
  sensitive   = true
}

variable "grafana_cloud_api_key" {
  type        = string
  description = "Grafana Cloud Prometheus API key"
  default     = ""
  sensitive   = true
}
