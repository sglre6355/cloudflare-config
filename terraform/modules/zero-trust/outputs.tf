output "one_time_pin_id" {
  description = "The identity provider for signing in with an emailed code."
  value       = cloudflare_zero_trust_access_identity_provider.one_time_pin.id
}
