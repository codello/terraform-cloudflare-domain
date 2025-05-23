resource "cloudflare_dns_record" "rapidmail_spf" {
  count = var.rapidmail.spf ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "rm01.${local.fqdn}"
  content = "return-cname.emailsys.net"
  ttl     = var.ttl

  comment = "SPF configuration for Rapidmail. ${local.managed}"
}

resource "cloudflare_dns_record" "rapidmail_tracking" {
  count = var.rapidmail.tracking ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = local.fqdn
  content = "tools-cname.emailsys.net"
  ttl     = var.ttl

  comment = "Tracking record for Rapidmail. ${local.managed}"
}
