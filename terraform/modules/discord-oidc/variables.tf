variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "name" {
  description = "Name used for the Cloudflare Worker and its KV namespace."
  type        = string
}

variable "script_path" {
  description = "Path to the bundled Worker script built from Aiko-IT-Systems/cloudflare-discord-oidc-worker."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for the Worker hostname."
  type        = string
}

variable "hostname" {
  description = "Public hostname for the Cloudflare Worker."
  type        = string
}

variable "application_id" {
  description = "Discord application ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{17,20}$", var.application_id))
    error_message = "The Discord application ID must contain 17 to 20 digits."
  }
}

variable "application_secret" {
  description = "OAuth2 client secret for the Discord application."
  type        = string
  sensitive   = true
}

variable "signing_key" {
  description = "Private RSA key in JWK format used to sign ID tokens. Must include a `kid` (key ID)."
  type        = string
  sensitive   = true
}

variable "user_groups" {
  description = "Access groups of Discord users, keyed by group name. Users are given by user ID (`ids`) or by role (`roles`). `roles` maps each server ID to a set of role IDs. To include all members of a server, include its @everyone role ID, which is the same as the server ID."
  type = map(object({
    ids   = optional(set(string), [])
    roles = optional(map(set(string)), {})
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for group in values(var.user_groups) : [
        for id in concat(
          tolist(group.ids),
          keys(group.roles),
          flatten([for ids in values(group.roles) : tolist(ids)]),
        ) : can(regex("^[0-9]{17,20}$", id))
      ]
    ]))
    error_message = "Each Discord ID must contain 17 to 20 digits."
  }

  validation {
    condition = alltrue([
      for group in values(var.user_groups) :
      length(group.ids) + length(flatten([for ids in values(group.roles) : tolist(ids)])) > 0
    ])
    error_message = "Each group needs at least one Discord user ID or role ID."
  }
}
