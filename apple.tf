resource "cloudflare_record" "apple_verification" {
  count = var.apple.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "apple-domain-verification=${var.apple.verification}"
  ttl     = var.ttl
}
