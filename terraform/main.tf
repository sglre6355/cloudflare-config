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

module "ilink_web" {
  source = "./ilink-web"

  account_id           = var.account_id
  zone_id              = module.zone[var.ilink_web.zone].id
  hostname             = var.ilink_web.hostname
  allowed_emails       = var.ilink_web.allowed_emails
  identity_provider_id = module.zero_trust.one_time_pin_id
}
