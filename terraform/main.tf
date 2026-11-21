module "zone" {
  source   = "./modules/zone"
  for_each = var.zones

  account_id = var.account_id
  name       = each.key
}

module "zero_trust" {
  source = "./zero-trust"

  account_id = var.account_id
}

# Build the Discord OIDC Worker from the source pinned in `nix/discord-oidc-worker.nix`.
data "external" "discord_oidc_worker" {
  program     = ["sh", "-c", "set -e; p=$(nix build --no-link --print-out-paths ..#discord-oidc-worker); jq -n --arg path \"$p/worker.js\" '{$path}'"]
  working_dir = path.root
}

module "ilink_web" {
  source = "./ilink-web"

  account_id                 = var.account_id
  zone_id                    = module.zone[var.ilink_web.zone].id
  hostname                   = var.ilink_web.hostname
  discord_application_id     = var.ilink_web.discord_application_id
  discord_application_secret = var.ilink_web_discord_application_secret
  discord_oidc_script_path   = data.external.discord_oidc_worker.result.path
  discord_oidc_signing_key   = var.ilink_web_discord_oidc_signing_key
  allowed_discord_users      = var.ilink_web.allowed_discord_users
}
