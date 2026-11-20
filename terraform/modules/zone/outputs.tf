output "id" {
  value = cloudflare_zone.this.id
}

output "name_servers" {
  description = "Name servers to set at the domain's registrar."
  value       = cloudflare_zone.this.name_servers
}
