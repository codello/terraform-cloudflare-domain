resource "cloudflare_record" "bimi" {
  count = var.bimi.logo_url != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "default._bimi.${local.fqdn}"
  content = "v=BIMI1; l=${var.bimi.logo_url}; a=${var.bimi.vmc_url}"
  ttl     = var.ttl
}
