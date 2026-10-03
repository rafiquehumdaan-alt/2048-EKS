output "zone_id" {
  description = "route 53 hosted zone ID"
  value       = aws_route53_zone.main.id
}

output "name_servers" {
  description = "route 53 nameservers for the delegated subdomain"
  value       = aws_route53_zone.main.name_servers
}

output "zone_name" {
  description = "route 53 hosted zone name"
  value       = aws_route53_zone.main.name
}

output "zone_arn" {
  description = "route 53 hosted zone arn"
  value       = aws_route53_zone.main.arn
}