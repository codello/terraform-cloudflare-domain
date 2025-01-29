resource "cloudflare_dns_record" "google_site_verification" {
  count = var.google.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "google-site-verification=${var.google.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Google. ${local.managed}"
}

resource "cloudflare_dns_record" "gmail" {
  for_each = var.google.gmail ? {
    "aspmx.l.google.com"      = 1
    "alt1.aspmx.l.google.com" = 5
    "alt2.aspmx.l.google.com" = 5
    "alt3.aspmx.l.google.com" = 10
    "alt4.aspmx.l.google.com" = 10
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  content  = each.key
  priority = each.value
  ttl      = var.ttl

  comment = "Gmail configuration for Google Workspace. ${local.managed}"
}
