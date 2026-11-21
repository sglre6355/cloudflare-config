# Discord authentication for Cloudflare Access.
#
# A Cloudflare Worker adapts Discord's OAuth2 authentication to OpenID Connect.
# Claims include the user's ID (`id`), server memberships (`guilds`), and roles
# (`roles:<server ID>`) for each server where `user_groups` names roles.

data "cloudflare_zero_trust_organization" "this" {
  account_id = var.account_id
}

locals {
  redirect_uri = "https://${data.cloudflare_zero_trust_organization.this.auth_domain}/cdn-cgi/access/callback"
  # Servers where a group names roles other than @everyone.
  role_guild_ids = sort(distinct(flatten([
    for group in values(var.user_groups) : [
      for guild_id, role_ids in group.roles : guild_id
      if length(setsubtract(role_ids, [guild_id])) > 0
    ]
  ])))
  # Use `roles` mode when role claims are required. This mode requests the
  # additional OAuth2 scope `guilds.members.read`.
  scope_mode = length(local.role_guild_ids) > 0 ? "roles" : "guilds"
}

# Store state for authentication flows in progress.
resource "cloudflare_workers_kv_namespace" "this" {
  account_id = var.account_id
  title      = var.name
}

# The bindings and compatibility date follow the Worker version pinned in
# `nix/discord-oidc-worker.nix`.
resource "cloudflare_workers_script" "this" {
  account_id         = var.account_id
  script_name        = var.name
  main_module        = "worker.js"
  content_file       = var.script_path
  content_sha256     = filesha256(var.script_path)
  compatibility_date = "2026-03-11"
  bindings = [
    { type = "kv_namespace", name = "KV", namespace_id = cloudflare_workers_kv_namespace.this.id },
    { type = "plain_text", name = "CLIENT_ID", text = var.application_id },
    { type = "plain_text", name = "ISSUER", text = "https://${var.hostname}" },
    { type = "plain_text", name = "REDIRECT_URIS", text = jsonencode([local.redirect_uri]) },
    # Retrieve roles using the user's OAuth2 authorization. No Discord bot is required.
    { type = "plain_text", name = "ROLE_SOURCE", text = "user" },
    { type = "plain_text", name = "ROLE_GUILD_IDS", text = jsonencode(local.role_guild_ids) },
    { type = "secret_text", name = "DISCORD_CLIENT_SECRET", text = var.application_secret },
    { type = "secret_text", name = "OIDC_SIGNING_PRIVATE_JWK", text = var.signing_key },
  ]
}

# Disable workers.dev and preview URLs to serve the Worker only at the
# configured hostname, which is used as the ID token issuer.
resource "cloudflare_workers_script_subdomain" "this" {
  account_id       = var.account_id
  script_name      = cloudflare_workers_script.this.script_name
  enabled          = false
  previews_enabled = false
}

resource "cloudflare_workers_custom_domain" "this" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = var.hostname
  service    = cloudflare_workers_script.this.script_name
}

resource "cloudflare_zero_trust_access_identity_provider" "this" {
  account_id = var.account_id
  name       = var.name
  type       = "oidc"
  config = {
    client_id     = var.application_id
    client_secret = var.application_secret
    auth_url      = "https://${var.hostname}/authorize/${local.scope_mode}"
    token_url     = "https://${var.hostname}/token"
    certs_url     = "https://${var.hostname}/jwks.json"
    pkce_enabled  = true
    scopes        = ["openid", "email", "profile"]
    claims        = concat(["id", "username", "guilds"], [for id in local.role_guild_ids : "roles:${id}"])
  }
}

resource "cloudflare_zero_trust_access_group" "this" {
  for_each = var.user_groups

  account_id = var.account_id
  name       = each.key
  include = concat(
    [for id in each.value.ids : {
      oidc = { identity_provider_id = cloudflare_zero_trust_access_identity_provider.this.id, claim_name = "id", claim_value = id }
    }],
    # Discord omits @everyone from member role lists. Check server membership
    # when the configured role ID matches the server ID (@everyone).
    flatten([for guild_id, role_ids in each.value.roles : [for id in role_ids : {
      oidc = (id == guild_id
        ? { identity_provider_id = cloudflare_zero_trust_access_identity_provider.this.id, claim_name = "guilds", claim_value = guild_id }
        : { identity_provider_id = cloudflare_zero_trust_access_identity_provider.this.id, claim_name = "roles:${guild_id}", claim_value = id }
      )
    }]]),
  )
}
