resource "aws_route53_zone" "main" {
  name = var.subdomain

  tags = var.tags
}

resource "cloudflare_dns_record" "delegation" {
  for_each = {
    ns1 = 0
    ns2 = 1
    ns3 = 2
    ns4 = 3
  }

  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  type    = "NS"
  content = aws_route53_zone.main.name_servers[each.value]
  ttl     = 300
}