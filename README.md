# Terraform CloudFlare Domain

This is a simple Terraform module that connects a CloudFlare-hosted domain to various service providers. The main goal of this module is to easily setup the required DNS records for E-Mail, verification, etc.

## Using the Module

You can use the module like so

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example_domain" {
  source = "github.com/codello/terraform-cloudflare-domain"

  zone_id = cloudflare_zone.example.id # required
  ttl     = 300 # optional

  microsoft {
    tenant  = "contoso"
    outlook = true
    # ...
  }

  google = {
    verification = "..."
  }

  # Additional Services

  dmarc_policy = ...
  bimi         = ...
  spf_policy   = {
    services = ["microsoft"]
    all      = "fail"
  }
}
```

### Configuring a subdomain

By default this module is used to configure the apex of a zone. However in certain cases you might only want to configure a subdomain with certain services. To do so you can use the `name` variable. The variable can be set to the name of a subdomain or the fully qualified domain name that you want to configure.

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example" {
  source = "github.com/codello/terraform-cloudflare-domain"

  zone_id = cloudflare_zone.example.id
  # We are configuring sub.exampe.com
  name = "sub"
  # This is equivalent
  #name = "sub.example.com"
}
```



## Configuring E-Mail Authentication

This module supports a flexible configuration for `DMARC`, `SPF` and `DKIM` keys.

### DMARC configuration

You can configure DMARC using the `dmarc_policy` variable. It can be set to an object containing the following keys.

| Key                   | Required | Description                                                          |
| --------------------- | -------- | -------------------------------------------------------------------- |
| `policy`              | Yes      | DMARC policy value. `"none"`, `"quarantine"` or `"reject"`           |
| `subdomain_policy`    | No       | Subdomain DMARC policy value. `"none"`, `"quarantine"` or `"reject"` |
| `percentage`          | No       | Percentage of filtered mails.                                        |
| `aggregate_addresses` | No       | List of E-Mail addresses to send aggregate reports to.               |
| `forensic_addresses`  | No       | List of E-Mail addresses to send forensic reports to.                |
| `dkim_alignment`      | No       | DKIM alignment. `"relaxed"` or `"strict"`                            |
| `spf_alignment`       | No       | SPF mode. `"relaxed"` or `"strict"`                                  |
| `forensic_options`    | No       | Sets the forensic options.                                           |
| `interval`            | No       | Sets the report interval.                                            |
| `format`              | No       | Sets the report format. Currently only `"afrf"` is allowed.          |

### SPF Configuration

You can configure the domain’s SPF policy using the `spf_policy` variable. It can be set to an object containing the following keys:

| Key           | Required | Description                                                  |
| ------------- | -------- | ------------------------------------------------------------ |
| `directives`  | No       | A list of SPF directives that are included verbatim.         |
| `redirect`    | No       | A SPF redirect policy (excluding the `redirect=` prefx).     |
| `exp_message` | No       | A message used for the `exp` value of the SPF record. If specified a dedicated DNS entry for the message is created and then linked in the `exp` part of the SPF record. |
| `fail`        | No       | One of `"pass"`, `"fail"`, `"softfail"`, `"neutral"` determining how emails should be treated that do not conform to the SPF policy. |
| `services`    | No       | A list of service names. For some service names the module contains known SPF `include:` policies. Using the `services` mechanism you can use these known values instead of writing your own `directives`. For example including `"microsoft"` in `services` will add `include:spf.protection.outlook.com` to the generated SPF policy. |

### BIMI Configuration

You can configure a BIMI record for the domain using the `bimi` variable. It can be set to an object containing the following keys:

| Key        | Required | Description                                                            |
| ---------- | -------- | ---------------------------------------------------------------------- |
| `logo_url` | Yes      | Sets the brand logo. Must be an URL indicating a compatible SVG image. |
| `vmc_url`  | No       | Sets the URL of the VMC certificate.                                   |

## Custom DKIM Keys

You can include DKIM keys for a domain using the `dkim_keys` map. Keys are domain names in the `_domainkey` namespace. Values are DKIM values. The map supports two formats:

- Raw DKIM keys: This is the usual case where you receive a DKIM key from a provider and want to add it to the domain. Paste the value as a value here.
- CNAME references. If the value looks like a domain name instead of a DKIM key the module will instead create a CNAME for the specified key. This is used by some providers such as Exchange Online.

Note that many service providers already implement their own DKIM records so in many cases you don’t have to set this variable manually.

The DKIM keys are somewhat special as the do support subdomains without setting the `domain` variable. Consider the following configuration:

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example_domain" {
  source = "github.com/codello/terraform-cloudflare-domain"

  zone_id = cloudflare_zone.example.id
  ttl 		= 300

  dkim_keys = {
    key1     = "k=rsa; t=s; p=MIG..."
    key2.sub = "another.host"
  }
}
```

This will create two records:

```
key1._domainkey.example.com.     300 IN TXT   "k=rsa; t=s; p=MIG..."
key2._domainkey.sub.example.com. 300 IN CNAME another.host.
```

## Service Providers

### Apple

Connect the domain to [Apple Business Manager](https://support.apple.com/business) by setting the `apple` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Apple verification code excluding the `"apple-domain-verification="` prefix. |

### Atlassian Cloud

Connect the domain to [Atlassian Cloud](https://www.atlassian.com) by setting the `atlassian` variable to an object containing the following keys:

| Key                  | Required | Description                                                  |
| -------------------- | -------- | ------------------------------------------------------------ |
| `verification`       | No       | Atlassian Domain Verification. Should not include the `"atlassian-domain-verification="` prefix. |
| `email_verification` | No       | The E-Mail verification string. Should not include the `"atlassian-sending-domain-verification="` prefix. If specified a `CNAME` record for bounces will be added as well. |

### Canva

Connect the domain to [Canva](https://www.canva.com) by setting the `canva` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Canva verification code excluding the `“canva-site-verification=”` prefix. |

### Facebook

Connect the domain to [Facebook](https://business.facebook.com) by setting the `facebook` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Facebook verification code excluding the `"facebook-domain-verification="` prefix. |

### Google

Connect the domain to [Google](https://workspace.google.com) by setting the `google` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Google Site verification code (excluding the `"google-site-verification="` prefix). |
| `gmail`        | No       | If `true` add GMail `MX` records.                            |

### IONOS

Connect the domain to [IONOS webhosting](https://www.ionos.de/hosting/webhosting) by setting the `ionos` variable to an object containing the following keys:

| Key            | Required | Description                                                |
| -------------- | -------- | ---------------------------------------------------------- |
| `verification` | No       | The IONOS verification code.                               |
| `email`        | No       | If `true` add `MX` records pointing to IONOS mail servers. |

### Mailcheap

Connect the domain to [Mailcheap](https://www.mailcheap.co/) by setting the `mailcheap` variable to an object containing the following keys:

| Key            | Required                  | Description                              |
| -------------- | ------------------------- | ---------------------------------------- |
| `verification` | No                        | The verification string for the domain.  |
| `host`         | Only if `email` is `true` | The hostname of your Mailcheap solution. |
| `email`        | No                        | If `true` add Mailcheap `MX` records.    |

### Mailgun

Connect the domain to [Mailgun](https://www.mailgun.com) by setting the `mailgun` variable to an object containing the following keys. If the `mailgun` object is set the module will automatically register the domain with Mailgun. You should not manually add the domain to Mailgun.

| Key             | Required | Description                                                  |
| --------------- | -------- | ------------------------------------------------------------ |
| `region`        | No       | The Mailgun region. Defaults to `"us"` but may be set to `"eu"`. |
| `dkim`          | No       | Automatically add the Mailgun DKIM keys. Defaults to `true`. |
| `spf`           | No       | `"auto"` or `"custom"`. If set to `"auto"` (default) add the SPF records returned by the Mailgun API to the domain. If `"custom"` use the `spf_policy` variable. You should not set a `spf_policy` when setting this to `"auto"`. |
| `tracking`      | No       | Add the tracking records to the domain. Defaults to `true`.  |
| `receiving`     | No       | Also add receiving `MX` records. Defaults to `true`.         |
| `spam_action`   | No       | Configure how Mailgun should handle Spam. Defaults to `"disabled"` |
| `dkim_key_size` | No       | Specifies the size of the DKIM key that should be generated. Defaults to `2048`. |

### Microsoft

Connect the domain to [Microsoft](https://www.microsoft.com/microsoft-365) by setting the `microsoft` variable to an object containing the following keys:

| Key            | Required                           | Description                                                  |
| -------------- | ---------------------------------- | ------------------------------------------------------------ |
| `verification` | No                                 | A verification string for the domain, excluding the `MS=` prefix. |
| `tenant`       | Only if `dkim` is `true`           | The name of your Microsoft tenant (the part before `.onmicrosoft.com`). |
| `domain`       | If `outlook`  or `dkim` are `true` | The ID of the domain. In simple cases this can be inferred automatically (basically by removing dashes). However in some cases this domain cannot be guessed. |
| `outlook`      | No                                 | If set to `true` the `MX` records for outlook will be created |
| `autodiscover` | No                                 | If set to `true` the Outlook Autodiscover record will be created. |
| `skype`        | No                                 | If set to `true` the SIP records for Skype will be created.  |
| `intune`       | No                                 | If set to `true` the MDM registration records for Intune will be created. |
| `dkim`         | No                                 | If set to `true` the Outlook DKIM keys will be added.        |

### MxRoute

Connect the domain to [MxRoute](https://mxroute.com) by setting the `mxroute` variable to an object containing the following keys:

| Key      | Required                   | Description                                                 |
| -------- | -------------------------- | ----------------------------------------------------------- |
| `email`  | No                         | If `true` add the MXRoute `MX` records.                     |
| `server` | Only if `email` is `true`. | The ID of your MXRoute server (excluding `".mxlogin.com"`). |
| `ip4`    | No                         | IPv4 address that will be added to the MxRoute SPF record.  |

### OVH

Connect the domain to [OVH](https://www.ovhcloud.com) by setting the `ovh` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The name of the subdomain used for verification.             |
| `server`       | No       | Specify the server of your mail solution. This will add the appropriate autodiscover record. |
| `email`        | No       | If set to `true` will add OVH `MX` records.                  |

### Pinterest

Connect the domain to [Pinterest](https://www.pinterest.de) by setting the `pinterest` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Pinterest verification code excluding the `"pinterest-site-verification="` prefix. |

### Rapidmail

Connect the domain to [Rapidmail](https://www.rapidmail.de) by setting the `rapidmail` variable to an object containing the following keys:

| Key        | Required | Description                                                  |
| ---------- | -------- | ------------------------------------------------------------ |
| `spf`      | No       | If set to `true` the Rapidmail SPF record is added to the domain. Rapidmail sends from a subdomain so in contrast to other services this adds the required subdomain `CNAME` for Rapidmail. |
| `tracking` | No       | If set to `true` the domain is setup as a Rapidmail tracking domain. This adds a CNAME record so you cannot use the domain for webhosting. |

### Rapidmail

Connect the domain to [Rapidmail](https://www.rapidmail.de) by setting the `rapidmail` variable to an object containing the following keys:

| Key        | Required | Description                                                  |
| ---------- | -------- | ------------------------------------------------------------ |
| `spf`      | No       | If set to `true` the Rapidmail SPF record is added to the domain. Rapidmail sends from a subdomain so in contrast to other services this adds the required subdomain `CNAME` for Rapidmail. |
| `tracking` | No       | If set to `true` the domain is setup as a Rapidmail tracking domain. This adds a CNAME record so you cannot use the domain for webhosting. |

## IDN Domain Names

IDNs should work with this module without any further configuration. However you might see some noise in Terraform plans because the Cloudflare API does not return IDNs for SRV records. This is functionally not a problem but might annoy you. To fix this you can set the `puny_domain` field to the puny-encoded version of the fully qualified domain name you are configuring (which might differ from the zone name if you are configuring a subdomain).

```terraform
resource "cloudflare_zone" "idn" {
  zone = "tëst.com"
}

module "example" {
  source = "github.com/codello/terraform-cloudflare-domain"

  zone_id     = cloudflare_zone.example.id
  # We are configuring süb.tëst.com
  name        = "süb"
  # This has no functional impact but might reduce some noise in plans.
  puny_domain = "xn--sb-xka.xn--tst-jma.com"
}
```

## Configuring Certificate Authorities

You can create `CAA` records by setting the `certificate_authorities` variable to a list of objects containing the following values:

| Key     | Required | Description                       |
| ------- | -------- | --------------------------------- |
| `flags` | Yes      | Sets the flags of the CAA record. |
| `tag`   | Yes      | Sets the tag of the CAA record.   |
| `value` | Yes      | Sets the value of the CAA record. |

## Configuring the TTL of records

You can set the TTL for created records using the optional `ttl` variable.
