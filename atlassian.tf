resource "cloudflare_record" "atlassian_verification" {
  count = var.atlassian.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "atlassian-domain-verification=${var.atlassian.verification}"
  ttl     = var.ttl
}

resource "cloudflare_record" "atlassian_email_bounces" {
  count = var.atlassian.email_verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "atlassian-bounces.${local.fqdn}"
  value   = "bounces.mail-us.atlassian.net"
  ttl     = var.ttl
}

resource "cloudflare_record" "atlassian_email_verification" {
  count = var.atlassian.email_verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "atlassian-sending-domain-verification=${var.atlassian.email_verification}"
  ttl     = var.ttl
}
