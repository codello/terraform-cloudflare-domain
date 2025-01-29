resource "cloudflare_dns_record" "pinterest_verification" {
  count = var.pinterest.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "pinterest-site-verification=${var.pinterest.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Pinterest. ${local.managed}"
}
