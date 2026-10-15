module "netbird_groups" {
  source   = "./modules/netbird/group"
  for_each = local.netbird_groups

  name = each.value.name
}

module "netbird_setup_keys" {
  source   = "./modules/netbird/setup-key"
  for_each = local.netbird_setup_keys

  name           = each.value.name
  type           = each.value.type
  ephemeral      = each.value.ephemeral
  usage_limit    = each.value.usage_limit
  expiry_seconds = each.value.expiry_seconds
  auto_groups    = each.value.auto_groups
}

module "netbird_networks" {
  source   = "./modules/netbird/network"
  for_each = local.netbird_networks

  name        = each.value.name
  description = each.value.description
}

module "netbird_network_resources" {
  source   = "./modules/netbird/network-resource"
  for_each = local.netbird_network_resources

  network_id  = each.value.network_id
  name        = each.value.name
  description = each.value.description
  address     = each.value.address
  groups      = each.value.groups
  enabled     = each.value.enabled
}

module "netbird_network_routers" {
  source   = "./modules/netbird/network-router"
  for_each = local.netbird_network_routers

  network_id  = each.value.network_id
  peer_groups = each.value.peer_groups
  masquerade  = each.value.masquerade
  metric      = each.value.metric
  enabled     = each.value.enabled
}

module "netbird_policies" {
  source   = "./modules/netbird/policy"
  for_each = local.netbird_policies

  name        = each.value.name
  description = each.value.description
  enabled     = each.value.enabled
  rules       = each.value.rules
}

module "netbird_nameserver_groups" {
  source   = "./modules/netbird/nameserver-group"
  for_each = local.netbird_nameserver_groups

  name                   = each.value.name
  description            = each.value.description
  enabled                = each.value.enabled
  primary                = each.value.primary
  domains                = each.value.domains
  search_domains_enabled = each.value.search_domains_enabled
  groups                 = each.value.groups
  nameservers            = each.value.nameservers
}

module "netbird_dns_zones" {
  source   = "./modules/netbird/dns-zone"
  for_each = local.netbird_dns_zones

  name                 = each.value.name
  domain               = each.value.domain
  distribution_groups  = each.value.distribution_groups
  enable_search_domain = each.value.enable_search_domain
  enabled              = each.value.enabled
}

module "netbird_dns_records" {
  source   = "./modules/netbird/dns-record"
  for_each = local.netbird_dns_records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl
}
