output "redirect_uri" {
  description = "OAuth2 redirect URI to register in the Discord application settings."
  value       = local.redirect_uri
}

output "identity_provider_id" {
  description = "Cloudflare Access identity provider ID for Discord authentication."
  value       = cloudflare_zero_trust_access_identity_provider.this.id
}

output "user_group_ids" {
  description = "Cloudflare Access group IDs, keyed by the names in `user_groups`."
  value       = { for name, group in cloudflare_zero_trust_access_group.this : name => group.id }
}
