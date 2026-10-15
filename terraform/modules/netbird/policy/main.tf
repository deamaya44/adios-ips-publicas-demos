resource "netbird_policy" "this" {
  name        = var.name
  description = var.description
  enabled     = var.enabled

  dynamic "rule" {
    for_each = var.rules
    content {
      name          = rule.value.name
      enabled       = rule.value.enabled
      action        = rule.value.action
      bidirectional = rule.value.bidirectional
      protocol      = rule.value.protocol
      ports         = rule.value.ports
      sources       = rule.value.sources
      destinations  = rule.value.destinations
    }
  }
}
