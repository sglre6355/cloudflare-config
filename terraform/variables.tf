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

variable "ilink_web" {
  description = "Cloudflare zone, public hostname, Discord application ID, and approved Discord users and roles for ilink-web."
  type = object({
    zone                   = string
    hostname               = string
    discord_application_id = string
    allowed_discord_users = object({
      ids   = optional(set(string), [])
      roles = optional(map(set(string)), {})
    })
  })
}

variable "ilink_web_discord_application_secret" {
  description = "OAuth2 client secret for ilink-web's Discord application."
  type        = string
  sensitive   = true
}

variable "ilink_web_discord_oidc_signing_key" {
  description = "Private RSA key in JWK format used by ilink-web's Discord OIDC Worker to sign ID tokens. Must include a `kid` (key ID)."
  type        = string
  sensitive   = true
}
