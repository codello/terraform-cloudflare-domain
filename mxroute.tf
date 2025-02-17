resource "cloudflare_dns_record" "mxroute_mx" {
  for_each = var.mxroute.email ? {
    "${var.mxroute.server}.mxlogin.com"       = 10
    "${var.mxroute.server}-relay.mxlogin.com" = 20
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  content  = each.key
  priority = each.value
  ttl      = var.ttl

  comment = "Mail configuration for MxRoute. ${local.managed}"
}
