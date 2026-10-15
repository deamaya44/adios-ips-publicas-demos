locals {
  base         = var.enable_base
  malla        = var.enable_malla && local.base
  certificados = var.enable_certificados && local.base

  grupo = module.netbird_groups
  red   = module.netbird_networks
  zona  = module.netbird_dns_zones

  netbird_groups = merge(
    local.base ? {
      routers = { name = "k8s-routers" }
      laptops = { name = "laptops" }
    } : {},
    local.malla ? {
      dns = { name = "k8s-dns" }
      bd  = { name = "k8s-bd" }
    } : {},
    local.certificados ? {
      gateway = { name = "k8s-gateway" }
    } : {},
  )

  netbird_setup_keys = local.base ? {
    routers = {
      name           = "k8s-routing-peer"
      type           = "reusable"
      ephemeral      = true
      usage_limit    = 0
      expiry_seconds = 2592000
      auto_groups    = [local.grupo.routers.id]
    }
    laptops = {
      name           = "laptops"
      type           = "reusable"
      ephemeral      = false
      usage_limit    = 5
      expiry_seconds = 604800
      auto_groups    = [local.grupo.laptops.id]
    }
  } : {}

  netbird_networks = local.base ? {
    cluster = {
      name        = "cluster-demo"
      description = "Services del cluster de la demo"
    }
  } : {}

  netbird_network_resources = merge(
    local.malla ? {
      kube_dns = {
        network_id  = local.red.cluster.id
        name        = "kube-dns"
        description = "DNS del cluster"
        address     = "${var.kube_dns_ip}/32"
        groups      = [local.grupo.dns.id]
        enabled     = true
      }
      postgres = {
        network_id  = local.red.cluster.id
        name        = "postgres"
        description = "Base de datos privada"
        address     = "${var.postgres_ip}/32"
        groups      = [local.grupo.bd.id]
        enabled     = true
      }
    } : {},
    local.certificados ? {
      gateway = {
        network_id  = local.red.cluster.id
        name        = "gateway"
        description = "NGINX Gateway: servicios web privados por HTTPS"
        address     = "${var.gateway_ip}/32"
        groups      = [local.grupo.gateway.id]
        enabled     = true
      }
    } : {},
  )

  netbird_network_routers = local.base ? {
    cluster = {
      network_id  = local.red.cluster.id
      peer_groups = [local.grupo.routers.id]
      masquerade  = true
      metric      = 9999
      enabled     = true
    }
  } : {}

  netbird_policies = merge(
    local.malla ? {
      dns = {
        name        = "laptops-dns-cluster"
        description = "Resolver nombres del cluster"
        enabled     = true
        rules = [{
          name          = "udp-53"
          enabled       = true
          action        = "accept"
          bidirectional = false
          protocol      = "udp"
          ports         = ["53"]
          sources       = [local.grupo.laptops.id]
          destinations  = [local.grupo.dns.id]
        }]
      }
      bd = {
        name        = "laptops-bd"
        description = "Solo Postgres, solo su puerto"
        enabled     = true
        rules = [{
          name          = "tcp-5432"
          enabled       = true
          action        = "accept"
          bidirectional = false
          protocol      = "tcp"
          ports         = ["5432"]
          sources       = [local.grupo.laptops.id]
          destinations  = [local.grupo.bd.id]
        }]
      }
    } : {},
    local.certificados ? {
      gateway = {
        name        = "laptops-gateway-https"
        description = "Solo HTTPS hacia el Gateway"
        enabled     = true
        rules = [{
          name          = "tcp-443"
          enabled       = true
          action        = "accept"
          bidirectional = false
          protocol      = "tcp"
          ports         = ["443"]
          sources       = [local.grupo.laptops.id]
          destinations  = [local.grupo.gateway.id]
        }]
      }
    } : {},
  )

  netbird_nameserver_groups = local.malla ? {
    kube_dns = {
      name                   = "kube-dns"
      description            = "DNS del cluster"
      enabled                = true
      primary                = false
      domains                = ["svc.cluster.local"]
      search_domains_enabled = false
      groups                 = [local.grupo.laptops.id]
      nameservers            = [{ ip = var.kube_dns_ip, ns_type = "udp", port = 53 }]
    }
  } : {}

  netbird_dns_zones = local.base ? {
    internal = {
      name                 = "interno"
      domain               = var.internal_domain
      distribution_groups  = [local.grupo.laptops.id]
      enable_search_domain = false
      enabled              = true
    }
  } : {}

  netbird_dns_records = merge(
    local.malla ? {
      bd = {
        zone_id = local.zona.internal.id
        name    = "bd.${var.internal_domain}"
        type    = "A"
        content = var.postgres_ip
        ttl     = 300
      }
    } : {},
    local.certificados ? {
      pgadmin = {
        zone_id = local.zona.internal.id
        name    = "pgadmin.${var.internal_domain}"
        type    = "A"
        content = var.gateway_ip
        ttl     = 300
      }
    } : {},
  )
}
