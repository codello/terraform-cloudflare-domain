locals {
  fqdn    = var.name == "@" || var.name == null ? data.external.idn.result.name : "${trimsuffix(trimsuffix(var.name, data.cloudflare_zone.zone.name), ".")}.${data.external.idn.result.name}"
  managed = "Managed by Terraform."
}

data "cloudflare_zone" "zone" {
  zone_id = var.zone_id
}

data "external" "idn" {
  program = ["python3", "-c", "import sys, json; json.dump({'name': sys.argv[1].encode('idna').decode('ascii')}, sys.stdout)", data.cloudflare_zone.zone.name]
}

resource "cloudflare_dns_record" "caa" {
  count = length(var.certificate_authorities)

  zone_id = var.zone_id
  type    = "CAA"
  name    = local.fqdn
  ttl     = var.ttl

  data = {
    flags = var.certificate_authorities[count.index].flags
    tag   = var.certificate_authorities[count.index].tag
    value = var.certificate_authorities[count.index].value
  }

  comment = local.managed
}
