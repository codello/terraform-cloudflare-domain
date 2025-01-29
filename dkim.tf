resource "cloudflare_dns_record" "dkim" {
  for_each = var.dkim_keys

  zone_id = var.zone_id
  type    = length(regexall("p=", each.value)) > 0 ? "TXT" : "CNAME"
  name = "${split(".", each.key)[0]}._domainkey${
    length(split(".", each.key)) <= 1 ? "" : ".${join(".", slice(split(".", each.key), 1, length(split(".", each.key))))}"
  }.${local.fqdn}"
  content = each.value
  ttl     = var.ttl

  comment = "${local.managed}"
}
