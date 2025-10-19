variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cert_manager_namespace" {
  description = "The namespace for cert-manager"
  type        = string
}

variable "external_dns_namespace" {
  description = "The namespace for external-dns"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}
