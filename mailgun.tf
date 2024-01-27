locals {
  # We do some hardcoding here which is maybe unelegant but it makes the rest of the code much more readable.
  # We make the following assumptions:
  # - There is a single SPF record and its hostname is the name of the domain in Mailgun.
  # - There is a single CNAME records used for tracking.
  # - There is exactly one DKIM key
  # - There may be multiple MX records

  mg_mx_records = var.mailgun != null ? [
    for record in mailgun_domain.domain[0].receiving_records_set :
    record if record.record_type == "MX"
  ] : []
  mg_dkim_record    = var.mailgun != null ? [for record in mailgun_domain.domain[0].sending_records_set : record if record.record_type == "TXT" && length(regexall("._domainkey.", record.name)) > 0][0] : null
  mg_spf_record     = var.mailgun != null ? [for record in mailgun_domain.domain[0].sending_records_set : record if record.record_type == "TXT" && length(regexall("^v=spf1", record.value)) > 0][0] : null
  mg_tracking_cname = var.mailgun != null ? [for record in mailgun_domain.domain[0].sending_records_set : record if record.record_type == "CNAME"][0] : null
}

resource "mailgun_domain" "domain" {
  count = var.mailgun != null ? 1 : 0

  name          = local.fqdn
  region        = var.mailgun.region
  spam_action   = var.mailgun.spam_action
  dkim_key_size = var.mailgun.dkim_key_size
}

resource "cloudflare_record" "mailgun_mx" {
  # We have to hardcode the number of MX records so that Terraform knows the number of resources at plan time.
  count = var.mailgun != null ? (var.mailgun.receiving ? 2 : 0) : 0

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = local.mg_mx_records[count.index].value
  priority = local.mg_mx_records[count.index].priority
  ttl      = var.ttl
}

resource "cloudflare_record" "mailgun_tracking" {
  count = var.mailgun != null ? (var.mailgun.tracking ? 1 : 0) : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = local.mg_tracking_cname.name
  value   = local.mg_tracking_cname.value
  ttl     = var.ttl
}

resource "cloudflare_record" "mailgun_dkim" {
  count = var.mailgun != null ? (var.mailgun.dkim ? 1 : 0) : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.mg_dkim_record.name
  value   = local.mg_dkim_record.value
  ttl     = var.ttl
}

resource "cloudflare_record" "mailgun_spf" {
  count = var.mailgun != null ? (var.mailgun.spf == "auto" ? 1 : 0) : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.mg_spf_record.name
  value   = local.mg_spf_record.value
  ttl     = var.ttl
}
