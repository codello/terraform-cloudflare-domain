locals {
  fqdn = var.name == "@" || var.name == null ? data.cloudflare_zone.zone.name : "${trimsuffix(trimsuffix(var.name, data.cloudflare_zone.zone.name), ".")}.${data.cloudflare_zone.zone.name}"
}

data "cloudflare_zone" "zone" {
  zone_id = var.zone_id
}

resource "cloudflare_record" "caa" {
  count = length(var.certificate_authorities)

  zone_id = var.zone_id
  type    = "CAA"
  name    = local.fqdn
  ttl     = var.ttl

  data {
    flags = var.certificate_authorities[count.index].flags
    tag   = var.certificate_authorities[count.index].tag
    value = var.certificate_authorities[count.index].value
  }
}
