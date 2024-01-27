resource "cloudflare_record" "mailcheap_verification" {
  count = var.mailcheap.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = var.mailcheap.verification
  ttl     = var.ttl
}

resource "cloudflare_record" "mailcheap_mx" {
  for_each = var.mailcheap.email ? {
    (var.mailcheap.host)   = 1
    "alt1.mymailcheap.com" = 5
    "alt2.mymailcheap.com" = 10
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = each.key
  priority = each.value
  ttl      = var.ttl
}
