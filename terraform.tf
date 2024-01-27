terraform {
  required_version = "~> 1.3"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    mailgun = {
      source  = "wgebis/mailgun"
      version = "~> 0.7"
    }
  }
}
