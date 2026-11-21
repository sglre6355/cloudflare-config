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

module "discord_oidc" {
  source = "./modules/discord-oidc"

  account_id         = var.account_id
  name               = "discord-oidc"
  script_path        = data.external.discord_oidc_worker.result.path
  zone_id            = module.zone[var.discord_oidc.zone].id
  hostname           = var.discord_oidc.hostname
  application_id     = var.discord_application_id
  application_secret = var.discord_application_secret
  signing_key        = var.discord_oidc_signing_key
}

module "ilink_web" {
  source = "./ilink-web"

  account_id           = var.account_id
  zone_id              = module.zone[var.ilink_web.zone].id
  hostname             = var.ilink_web.hostname
  allowed_emails       = var.ilink_web.allowed_emails
  identity_provider_id = module.zero_trust.one_time_pin_id
}
