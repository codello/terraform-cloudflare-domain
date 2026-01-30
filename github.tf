resource "cloudflare_dns_record" "github_verification" {
  count = var.github.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "${var.github.verification.key}.${local.fqdn}"
  content = var.github.verification.value
  ttl     = var.ttl

  comment = "Domain verification for GitHub. ${local.managed}"
}
