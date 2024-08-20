resource "cloudflare_record" "ovh_verification" {
  count = var.ovh.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "${var.ovh.verification}.${local.fqdn}"
  content = "ovh.com"
  ttl     = var.ttl
}

resource "cloudflare_record" "ovh_autodiscover" {
  count = var.ovh.server != null ? 1 : 0

  zone_id = var.zone_id
  type    = "SRV"
  name    = "_autodiscover._tcp.${local.fqdn}"
  ttl     = var.ttl

  data {
    service  = "_autodiscover"
    proto    = "_tcp"
    name     = local.fqdn
    priority = 0
    weight   = 0
    port     = 443
    target   = var.ovh.server
  }
}

resource "cloudflare_record" "ovh_mx" {
  for_each = var.ovh.email ? {
    "mx3.mail.ovh.net" = 100
    "mx2.mail.ovh.net" = 50
    "mx1.mail.ovh.net" = 5
    "mx0.mail.ovh.net" = 1
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  content  = each.key
  priority = each.value
  ttl      = var.ttl
}
