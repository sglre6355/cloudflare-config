# Zero Trust settings shared by every Access application, on every domain.

# Signing in with a one-time code sent by email. An account can have only one.
resource "cloudflare_zero_trust_access_identity_provider" "one_time_pin" {
  account_id = var.account_id
  name       = "One-time PIN"
  type       = "onetimepin"
  config     = {}
}
