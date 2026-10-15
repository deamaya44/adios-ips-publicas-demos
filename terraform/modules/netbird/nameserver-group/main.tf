resource "netbird_nameserver_group" "this" {
  name                   = var.name
  description            = var.description
  enabled                = var.enabled
  primary                = var.primary
  domains                = var.domains
  search_domains_enabled = var.search_domains_enabled
  groups                 = var.groups
  nameservers            = var.nameservers
}
