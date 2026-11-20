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
