# Cloudflare infrastructure for ilink-web (https://github.com/sglre6355/ilink-web).
#
# Cloudflare Tunnel exposes the web application, and Cloudflare Access
# restricts access to approved Discord users through a Discord application of
# its own.
#
# TURN relays video traffic separately.

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = var.account_id
  name       = "ilink-web"
  config_src = "local"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

resource "cloudflare_dns_record" "this" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

module "discord_oidc" {
  source = "../modules/discord-oidc"

  account_id = var.account_id
  name       = "ilink-web-discord-oidc"
  # Outside the Access application, which covers only `hostname`. The Worker
  # serves the sign-in itself, so it must not need one.
  hostname           = "discord.oidc.${var.hostname}"
  zone_id            = var.zone_id
  script_path        = var.discord_oidc_script_path
  application_id     = var.discord_application_id
  application_secret = var.discord_application_secret
  signing_key        = var.discord_oidc_signing_key

  user_groups = {
    "ilink-web viewers" = var.allowed_discord_users
  }
}

resource "cloudflare_zero_trust_access_policy" "this" {
  account_id = var.account_id
  name       = "ilink-web viewers"
  decision   = "allow"
  include    = [{ group = { id = module.discord_oidc.user_group_ids["ilink-web viewers"] } }]
}

# Require authentication through Cloudflare Access.
resource "cloudflare_zero_trust_access_application" "this" {
  account_id       = var.account_id
  name             = "ilink-web"
  type             = "self_hosted"
  domain           = var.hostname
  session_duration = "24h"
  allowed_idps     = [module.discord_oidc.identity_provider_id]
  # Redirect users to the configured identity provider.
  auto_redirect_to_identity = true
  app_launcher_visible      = false
  policies = [{
    id         = cloudflare_zero_trust_access_policy.this.id
    precedence = 1
  }]
}

# Cloudflare returns the TURN API token only when the key is created.
# Terraform retains the token in its state.
resource "cloudflare_calls_turn_app" "this" {
  account_id = var.account_id
  name       = "ilink-web"
}
