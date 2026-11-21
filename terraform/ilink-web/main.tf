# Cloudflare infrastructure for ilink-web (https://github.com/sglre6355/ilink-web).
#
# Cloudflare Tunnel exposes the web application, and Cloudflare Access
# restricts access to members of approved Access groups.
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

resource "cloudflare_zero_trust_access_policy" "this" {
  account_id = var.account_id
  name       = "ilink-web viewers"
  decision   = "allow"
  include    = [for id in var.allowed_group_ids : { group = { id = id } }]
}

# Require authentication through Cloudflare Access.
resource "cloudflare_zero_trust_access_application" "this" {
  account_id       = var.account_id
  name             = "ilink-web"
  type             = "self_hosted"
  domain           = var.hostname
  session_duration = "24h"
  allowed_idps     = [var.identity_provider_id]
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
