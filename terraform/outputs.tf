output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller"
  value       = module.addons_iam.aws_load_balancer_controller_role_arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by ExternalDNS"
  value       = module.addons_iam.external_dns_role_arn
}

output "eks_route53_zone_id" {
  description = "Route 53 hosted zone ID for eks.humdaan.co.uk"
  value       = module.dns.zone_id
}