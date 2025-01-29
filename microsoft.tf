locals {
  ms_domain = var.microsoft.domain != null ? var.microsoft.domain : replace(replace(local.fqdn, "-", ""), ".", "-")
}

resource "cloudflare_dns_record" "ms_verification" {
  count = var.microsoft.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = "MS=${var.microsoft.verification}"
  ttl     = var.ttl

  comment = "Domain verification for Microsoft. ${local.managed}"
}

resource "cloudflare_dns_record" "ms_mx" {
  count = var.microsoft.outlook ? 1 : 0

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  content  = "${local.ms_domain}.mail.protection.outlook.com"
  priority = 0
  ttl      = var.ttl

  comment = "Exchange mail configuration. ${local.managed}"
}

resource "cloudflare_dns_record" "ms_autodiscover" {
  count = var.microsoft.autodiscover ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "autodiscover.${local.fqdn}"
  content = "autodiscover.outlook.com"
  ttl     = var.ttl

  comment = "Exchange autodiscover configuration. ${local.managed}"
}

resource "cloudflare_dns_record" "sip" {
  count = var.microsoft.skype ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "sip.${local.fqdn}"
  content = "sipdir.online.lync.com"
  ttl     = var.ttl

  comment = "SIP configuration for Teams. ${local.managed}"
}

resource "cloudflare_dns_record" "lyncdiscover" {
  count = var.microsoft.skype ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "lyncdiscover.${local.fqdn}"
  content = "webdir.online.lync.com"
  ttl     = var.ttl

  comment = "Lync configuration for Teams. ${local.managed}"
}

resource "cloudflare_dns_record" "_sip" {
  count = var.microsoft.skype ? 1 : 0

  zone_id = var.zone_id
  type    = "SRV"
  name    = "_sip._tls.${local.fqdn}"
  ttl     = var.ttl

  data = {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }

  comment = "SIP configuration for Teams. ${local.managed}"
}

resource "cloudflare_dns_record" "_sipfederationtls" {
  count = var.microsoft.skype ? 1 : 0

  zone_id = var.zone_id
  type    = "SRV"
  name    = "_sipfederationtls._tcp.${local.fqdn}"
  ttl     = var.ttl

  data = {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }

  comment = "SIP configuration for Teams. ${local.managed}"
}

resource "cloudflare_dns_record" "enterpriseregistration" {
  count = var.microsoft.intune ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "enterpriseregistration.${local.fqdn}"
  content = "enterpriseregistration.windows.net"
  ttl     = var.ttl

  comment = "Intune registration. ${local.managed}"
}

resource "cloudflare_dns_record" "enterpriseenrollment" {
  count = var.microsoft.intune ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "enterpriseenrollment.${local.fqdn}"
  content = "enterpriseenrollment.manage.microsoft.com"
  ttl     = var.ttl

  comment = "Intune enrollment. ${local.managed}"
}

resource "cloudflare_dns_record" "ms_dkim" {
  for_each = toset(var.microsoft.dkim ? ["selector1", "selector2"] : [])

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "${each.value}._domainkey.${local.fqdn}"
  content = "${each.value}-${local.ms_domain}._domainkey.${var.microsoft.tenant}.onmicrosoft.com"
  ttl     = var.ttl

  comment = "DKIM for Exchange. ${local.managed}"
}
