resource "cloudflare_dns_record" "atlassian_verification" {
  count = var.atlassian.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "atlassian-domain-verification=${var.atlassian.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Atlassian Cloud. ${local.managed}"
}

resource "cloudflare_dns_record" "atlassian_email_bounces" {
  count = var.atlassian.email_verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "atlassian-bounces.${local.fqdn}"
  content = "bounces.mail-us.atlassian.net"
  ttl     = var.ttl

  comment = "Email bounce record for Atlassian Cloud. ${local.managed}"
}

resource "cloudflare_dns_record" "atlassian_email_verification" {
  count = var.atlassian.email_verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "atlassian-sending-domain-verification=${var.atlassian.email_verification}"
  ttl     = var.ttl

  comment = "Email domain verification for Atlassian Cloud. ${local.managed}"
}
