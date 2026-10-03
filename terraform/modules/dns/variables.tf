variable "subdomain" {
  description = "Subdomain delegated to route 53"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the parent domain"
  type        = string
}

variable "tags" {
  description = "Tags applied to route 53 resources"
  type        = map(string)
  default     = {}
}