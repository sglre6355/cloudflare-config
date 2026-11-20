output "zone_name_servers" {
  description = "Name servers to set at each domain's registrar."
  value       = { for name, zone in module.zone : name => zone.name_servers }
}
