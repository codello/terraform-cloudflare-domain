# ---------------------------------------------------------------------------------------------------------------------
# GENERAL VARIABLES
# These variables configure the domain and all DNS records created by this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "zone_id" {
  type        = string
  description = "The CloudFlare Zone ID corresponding to the domain that should be modified."
}

variable "name" {
  type        = string
  description = "The name of the record (aka the name of the subdomain). Defaults to the root of the zone."
  default     = "@"
}

variable "puny_domain" {
  type        = string
  default     = null
  description = "A puny-encoded version of the fully qualified domain name. This is used for SRV records to remove some noise from plans."
}

variable "ttl" {
  type        = number
  default     = null
  description = "The TTL used for created DNS records."
}

# ---------------------------------------------------------------------------------------------------------------------
# SPAM PROTECTION
# Configure spf, dkim, dmarc, and bimi for this domain.
# ---------------------------------------------------------------------------------------------------------------------
variable "spf_policy" {
  type = object({
    services    = optional(list(string), [])
    directives  = optional(list(string), [])
    redirect    = optional(string)
    all         = optional(string, "neutral")
    exp_message = optional(string)
  })
  default     = null
  description = "The SPF policy used to create a SPF record. By default no SPF record is created."

  validation {
    condition     = var.spf_policy == null ? true : contains(["pass", "fail", "softfail", "neutral"], var.spf_policy.all)
    error_message = "The all value must be one of pass, fail, softfail, and neutral."
  }
}

variable "dkim_keys" {
  type        = map(string)
  default     = {}
  description = "A set of DKIM keys where the keys are the names of the respective keys."
}

variable "dmarc_policy" {
  type = object({
    # p
    policy = string
    # sp
    subdomain_policy = optional(string)
    # pct
    percentage = optional(number)
    # rua
    aggregate_addresses = optional(list(string), [])
    # ruf
    forensic_addresses = optional(list(string), [])
    # adkim
    dkim_alignment = optional(string)
    # aspf
    spf_alignment = optional(string)
    # fo
    forensic_options = optional(string)
    # ri
    interval = optional(number)
    # rf
    format = optional(string)
  })
  default     = null
  description = "The value of the DMARC TXT entry."

  validation {
    condition     = var.dmarc_policy == null ? true : contains(["none", "quarantine", "reject"], var.dmarc_policy.policy)
    error_message = "The policy must be a valid DMARC policy string."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.subdomain_policy == null ? true : contains(["none", "quarantine", "reject"], var.dmarc_policy.subdomain_policy))
    error_message = "The subdomain_policy must be a valid DMARC policy string."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.percentage == null ? true : (ceil(var.dmarc_policy.percentage) == var.dmarc_policy.percentage && var.dmarc_policy.percentage >= 0 && var.dmarc_policy.percentage <= 100))
    error_message = "The DMARC percentage needs to be an integer between 0 and 100."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.dkim_alignment == null ? true : contains(["relaxed", "strict"], var.dmarc_policy.dkim_alignment))
    error_message = "DKIM alignment needs to be relaxed or strict."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.spf_alignment == null ? true : contains(["relaxed", "strict"], var.dmarc_policy.spf_alignment))
    error_message = "SPF alignment needs to be relaxed or strict."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.forensic_options == null ? true : contains(["all", "any", "dkim", "spf"], var.dmarc_policy.forensic_options))
    error_message = "Forensic reporting options must be a valid value."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.interval == null ? true : ceil(var.dmarc_policy.interval) == var.dmarc_policy.interval)
    error_message = "The report interval needs to be an integer."
  }

  validation {
    condition     = var.dmarc_policy == null ? true : (var.dmarc_policy.format == null ? true : var.dmarc_policy.format == "afrf")
    error_message = "The only supported report format is afrf."
  }
}

variable "bimi" {
  type = object({
    logo_url = optional(string)
    vmc_url  = optional(string, "")
  })
  default     = {}
  description = "Brand Indicators for Message Identification configuration."
}

variable "certificate_authorities" {
  type = list(object({
    flags = number
    tag   = string
    value = string
  }))
  default     = []
  description = "A list of certificate authorities to be configured as CAA records."
}

# ---------------------------------------------------------------------------------------------------------------------
# SERVICE PROVIDERS
# Configure the connection to different service providers.
# ---------------------------------------------------------------------------------------------------------------------
variable "apple" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configures options to connect the domain to Apple Business Manager."
}

variable "atlassian" {
  type = object({
    verification       = optional(string)
    email_verification = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to Atlassian."
}

variable "canva" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configures options to connect the domain to Canva."
}

variable "facebook" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configures options to connect the domain to Facebook."
}

variable "google" {
  type = object({
    verification = optional(string)
    gmail        = optional(bool, false)
  })
  default     = {}
  description = "Configures options to connect the domain to Google."
}

variable "ionos" {
  type = object({
    verification = optional(string)
    email        = optional(bool, false)
  })
  default     = {}
  description = "Configure options to connect the domain to IONOS."
}

variable "mailcheap" {
  type = object({
    verification = optional(string)
    email        = optional(bool, false)
    host         = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to Mailcheap."
}

variable "mailgun" {
  type = object({
    region = optional(string, "us")
    dkim   = optional(bool, true)
    spf    = optional(string, "auto") # Either "auto" or "custom". "custom" uses the module's SPF record. If "auto" you must not not
    # specify a spf_policy.
    tracking      = optional(bool, true)
    receiving     = optional(bool, true)
    spam_action   = optional(string, "disabled")
    dkim_key_size = optional(number, 2048)
  })
  default     = null
  description = "Configures options to connect the domain to Mailgun. Note that SPF and DKIM are required to verify the domain."
}

variable "microsoft" {
  type = object({
    verification = optional(string)
    tenant       = optional(string)
    domain       = optional(string)
    outlook      = optional(bool, false)
    autodiscover = optional(bool, false)
    skype        = optional(bool, false)
    intune       = optional(bool, false)
    dkim         = optional(bool, false)
  })
  default     = {}
  description = "Configures options to connect the domain to Microsoft."
}

variable "mxroute" {
  type = object({
    email  = optional(bool, false)
    server = optional(string)
    ip4    = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to MXRoute."
}

variable "ovh" {
  type = object({
    verification = optional(string)
    email        = optional(bool, false)
    server       = optional(string)
  })
  default     = {}
  description = "Configures options to connect the domain to OVH."
}

variable "pinterest" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to Pinterest."
}

variable "rapidmail" {
  type = object({
    spf      = optional(bool, false)
    tracking = optional(bool, false)
  })
  default     = {}
  description = "Configures options to connect the domain to Rapidmail."
}
