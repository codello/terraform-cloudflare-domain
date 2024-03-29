resource "cloudflare_record" "rapidmail_spf" {
  count = var.rapidmail.spf ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "rm01.${local.fqdn}"
  value   = "return-cname.emailsys.net"
  ttl     = var.ttl
}

resource "cloudflare_record" "rapidmail_tracking" {
  count = var.rapidmail.tracking ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = local.fqdn
  value   = "tools-cname.emailsys.net"
  ttl     = var.ttl
}
