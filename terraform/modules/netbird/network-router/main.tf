resource "netbird_network_router" "this" {
  network_id  = var.network_id
  peer_groups = var.peer_groups
  masquerade  = var.masquerade
  metric      = var.metric
  enabled     = var.enabled
}
