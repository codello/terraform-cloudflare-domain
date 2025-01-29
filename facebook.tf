resource "cloudflare_dns_record" "facebook_verification" {
  count = var.facebook.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "facebook-domain-verification=${var.facebook.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Meta Business Suite. ${local.managed}"
}
