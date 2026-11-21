variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for the application hostname."
  type        = string
}

variable "hostname" {
  description = "Public hostname for ilink-web (e.g. `camera.example.com`)."
  type        = string
}

variable "discord_application_id" {
  description = "ID of the Discord application that ilink-web's viewers sign in with."
  type        = string
}

variable "discord_application_secret" {
  description = "OAuth2 client secret for the Discord application."
  type        = string
  sensitive   = true
}

variable "discord_oidc_script_path" {
  description = "Path to the bundled Discord OIDC Worker script."
  type        = string
}

variable "discord_oidc_signing_key" {
  description = "Private RSA key in JWK format used by the Discord OIDC Worker to sign ID tokens. Must include a `kid` (key ID)."
  type        = string
  sensitive   = true
}

variable "allowed_discord_users" {
  description = "Discord users permitted to access ilink-web, by user ID (`ids`) or by role (`roles`). `roles` maps each server ID to a set of role IDs. To allow all members of a server, include its @everyone role ID, which is the same as the server ID."
  type = object({
    ids   = optional(set(string), [])
    roles = optional(map(set(string)), {})
  })
}
