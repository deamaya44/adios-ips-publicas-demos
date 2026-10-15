resource "netbird_dns_zone" "this" {
  name                 = var.name
  domain               = var.domain
  distribution_groups  = var.distribution_groups
  enable_search_domain = var.enable_search_domain
  enabled              = var.enabled
}
