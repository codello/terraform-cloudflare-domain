locals {
  service_spf = {
    atlassian = "include:_spf.atlassian.net"
    google    = "include:_spf.google.com"
    ionos     = ["include:_spf.perfora.net", "include:_spf.kundenserver.de"]
    mailcheap = concat(
      var.mailcheap.host != null ? ["a:${var.mailcheap.host}"] : [],
      ["a:relay.mymailcheap.com"]
    )
    mailchimp  = "include:servers.mcsv.net"
    mailgun    = "include:mailgun.org"
    mailgun-eu = "include:eu.mailgun.org"
    mailjet    = "include:spf.mailjet.com"
    microsoft  = "include:spf.protection.outlook.com"
    mxroute = concat(
      var.mxroute.ip4 != null ? ["ip4:${var.mxroute.ip4}"] : [],
      ["include:mxroute.com"]
    )
    ovh         = "include:mx.ovh.com"
    questionpro = "include:_spf.qp-mail.eu"
    sendinblue  = "include:spf.sendinblue.com"
  }
  spf_fail_policies = {
    pass     = "+all",
    fail     = "-all"
    softfail = "~all"
    neutral  = "?all"
  }
  spf_record = var.spf_policy != null ? join(" ", concat(
    ["v=spf1"],
    var.spf_policy.exp_message != null ? ["exp=exp.spf.${local.fqdn}"] : [],
    flatten([for service in var.spf_policy.services : local.service_spf[service]]),
    var.spf_policy.directives,
    var.spf_policy.redirect != null ? ["redirect=${var.spf_policy.redirect}"] : [],
    var.spf_policy.redirect == null ? [local.spf_fail_policies[var.spf_policy.all]] : []
  )) : null
}

resource "cloudflare_dns_record" "spf" {
  count = var.spf_policy != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  content = local.spf_record
  ttl     = var.ttl

  comment = "SPF record. ${local.managed}"
}

resource "cloudflare_dns_record" "spf_exp" {
  count = var.spf_policy != null ? (var.spf_policy.exp_message != null ? 1 : 0) : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "exp.spf.${local.fqdn}"
  content = var.spf_policy.exp_message
  ttl     = var.ttl

  comment = "SPF Exp record. ${local.managed}"
}
