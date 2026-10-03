variable "oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "route53_zone_arn" {
  description = "ARN of the Route 53 hosted zone managed by ExternalDNS"
  type        = string
}