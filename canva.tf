resource "cloudflare_dns_record" "canva_verification" {
  count = var.canva.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "canva-site-verification=${var.canva.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Canva. ${local.managed}"
}
