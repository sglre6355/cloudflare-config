output "tunnel_token" {
  description = "Cloudflare Tunnel token for the cloudflared `TUNNEL_TOKEN` environment variable."
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
  sensitive   = true
}

output "turn_key_id" {
  description = "TURN key ID for the ilink-web `TURN_KEY_ID` environment variable."
  value       = cloudflare_calls_turn_app.this.uid
}

output "turn_key_api_token" {
  description = "TURN API token for the ilink-web `TURN_KEY_API_TOKEN` environment variable."
  value       = cloudflare_calls_turn_app.this.key
  sensitive   = true
}
