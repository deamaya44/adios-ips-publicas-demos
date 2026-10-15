resource "netbird_setup_key" "this" {
  name           = var.name
  type           = var.type
  ephemeral      = var.ephemeral
  usage_limit    = var.usage_limit
  expiry_seconds = var.expiry_seconds
  auto_groups    = var.auto_groups
}
