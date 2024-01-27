resource "cloudflare_record" "ionos_mx" {
  for_each = var.ionos.email ? {
    "mx00.ionos.de" = 10
    "mx01.ionos.de" = 11
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = each.key
  priority = each.value
  ttl      = var.ttl
}

resource "cloudflare_record" "ionos_verification" {
  count = var.ionos.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = var.ionos.verification
  ttl     = var.ttl
}
