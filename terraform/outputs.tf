output "zone_name_servers" {
  description = "Name servers to set at each domain's registrar."
  value       = { for name, zone in module.zone : name => zone.name_servers }
}

output "discord_oidc_redirect_uri" {
  description = "OAuth2 redirect URI to register in the Discord application settings."
  value       = module.discord_oidc.redirect_uri
}

output "ilink_web" {
  description = "Tunnel token and TURN credentials for deploying ilink-web."
  value = {
    tunnel_token       = module.ilink_web.tunnel_token
    turn_key_id        = module.ilink_web.turn_key_id
    turn_key_api_token = module.ilink_web.turn_key_api_token
  }
  sensitive = true
}
