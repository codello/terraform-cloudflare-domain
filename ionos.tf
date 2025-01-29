resource "cloudflare_dns_record" "ionos_verification" {
  count = var.ionos.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = var.ionos.verification
  ttl     = var.ttl

  comment = "Domain verification for IONOS. ${local.managed}"
}

resource "cloudflare_dns_record" "ionos_mx" {
  for_each = var.ionos.email ? {
    "mx00.ionos.de" = 10
    "mx01.ionos.de" = 11
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  content  = each.key
  priority = each.value
  ttl      = var.ttl

  comment = "Mail configuration for IONOS. ${local.managed}"
}
