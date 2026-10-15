output "routers_setup_key" {
  description = "Va al Secret netbird-setup-key del cluster."
  value       = try(module.netbird_setup_keys["routers"].key, null)
  sensitive   = true
}

output "laptops_setup_key" {
  description = "Para unir tu laptop: netbird up --setup-key-file ..."
  value       = try(module.netbird_setup_keys["laptops"].key, null)
  sensitive   = true
}

output "bd_fqdn" {
  description = "Nombre interno de la base de datos. Solo resuelve dentro de la malla."
  value       = try(module.netbird_dns_records["bd"].name, null)
}

output "pgadmin_url" {
  description = "pgAdmin de solo lectura con certificado de Let's Encrypt. Solo abre dentro de la malla."
  value       = try("https://${module.netbird_dns_records["pgadmin"].name}", null)
}
