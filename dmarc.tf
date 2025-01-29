locals {
  forensic_options = {
    all  = 0
    any  = 1
    dkim = "d"
    spf  = "s"
  }
  dmarc_components = var.dmarc_policy == null ? null : [
    "v=DMARC1",
    "p=${var.dmarc_policy.policy}",
    var.dmarc_policy.subdomain_policy == null ? null : "sp=${var.dmarc_policy.subdomain_policy}",
    var.dmarc_policy.percentage == null ? null : "pct=${var.dmarc_policy.percentage}",
    length(var.dmarc_policy.aggregate_addresses) == 0 ? null : "rua=${join(",", [for address in var.dmarc_policy.aggregate_addresses : "mailto:${address}"])}",
    length(var.dmarc_policy.forensic_addresses) == 0 ? null : "ruf=${join(",", [for address in var.dmarc_policy.forensic_addresses : "mailto:${address}"])}",
    var.dmarc_policy.dkim_alignment == null ? null : "adkim=${substr(var.dmarc_policy.dkim_alignment, 0, 1)}",
    var.dmarc_policy.spf_alignment == null ? null : "aspf=${substr(var.dmarc_policy.spf_alignment, 0, 1)}",
    var.dmarc_policy.forensic_options == null ? null : "fo=${local.forensic_options[var.dmarc_policy.forensic_options]}",
    var.dmarc_policy.interval == null ? null : "ri=${var.dmarc_policy.interval}",
    var.dmarc_policy.format == null ? null : "rf=${var.dmarc_policy.format}"
  ]
}

resource "cloudflare_dns_record" "dmarc" {
  count = var.dmarc_policy != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "_dmarc.${local.fqdn}"
  content = join("; ", compact(local.dmarc_components))
  ttl     = var.ttl

  comment = "Domain DMARC policy. ${local.managed}"
}
