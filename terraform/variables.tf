variable "state_passphrase" {
  description = "Passphrase to encrypt the state."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "The Cloudflare account everything here belongs to."
  type        = string
}

variable "zones" {
  description = "Every domain on the account."
  type        = set(string)
}

variable "discord_application_id" {
  description = "ID of the Discord application used for signing in to Cloudflare Access."
  type        = string
}

variable "discord_application_secret" {
  description = "OAuth2 client secret for the Discord application."
  type        = string
  sensitive   = true
}

variable "discord_oidc" {
  description = "Cloudflare zone and public hostname for the Discord OIDC Worker."
  type = object({
    zone     = string
    hostname = string
  })
}

variable "discord_oidc_signing_key" {
  description = "Private RSA key in JWK format used by the Discord OIDC Worker to sign ID tokens. Must include a `kid` (key ID)."
  type        = string
  sensitive   = true
}

variable "ilink_web" {
  description = "Cloudflare zone, public hostname, and permitted email addresses for ilink-web."
  type = object({
    zone           = string
    hostname       = string
    allowed_emails = set(string)
  })
}
