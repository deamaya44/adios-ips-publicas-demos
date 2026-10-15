resource "netbird_network_resource" "this" {
  network_id  = var.network_id
  name        = var.name
  description = var.description
  address     = var.address
  groups      = var.groups
  enabled     = var.enabled
}
