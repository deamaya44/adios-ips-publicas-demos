output "id" {
  value = netbird_setup_key.this.id
}

output "key" {
  value     = netbird_setup_key.this.key
  sensitive = true
}
