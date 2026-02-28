locals {
  netmask              = cidrnetmask(var.network.ipv4_cidr)
  gateway_ipv4_address = cidrhost(var.network.ipv4_cidr, 1)
  gateway_ipv6_address = var.network.ipv6_cidr != null ? cidrhost(var.network.ipv6_cidr, 1) : null

  # Use the variable if provided, otherwise calculate from offset
  dhcp_start = coalesce(var.network.dhcp_start, cidrhost(var.network.ipv4_cidr, var.network.dhcp_offset))
  dhcp_end   = coalesce(var.network.dhcp_end, cidrhost(var.network.ipv4_cidr, var.network.dhcp_offset + var.network.dhcp_count))

  # IPv6 setup
  ipv6_ips = var.network.ipv6_cidr != null ? [
    {
      family  = "ipv6"
      address = local.gateway_ipv6_address
      prefix  = tonumber(split("/", var.network.ipv6_cidr)[1])
    },
  ] : []
}

resource "libvirt_network" "network" {
  name      = var.network.name
  autostart = var.network.autostart

  domain = {
    name       = var.network.domain
    local_only = "yes"
  }

  bridge = {
    name = var.network.bridge
  }

  dns = {
    enabled    = true
    local_only = true

    forwarders = [
      for addr in var.network.dns_forwarders : { addr = addr }
    ]

    host = concat(
      [for h in var.static_hosts : {
        ip        = h.ipv4
        hostnames = [{ hostname = h.hostname }]
      }],
      [for h in var.static_hosts : {
        ip        = h.ipv6
        hostnames = [{ hostname = h.hostname }]
      } if h.ipv6 != null]
    )
  }

  ips = concat(
    [
      {
        address = local.gateway_ipv4_address
        netmask = local.netmask

        dhcp = {
          enabled = true
          ranges  = [{ start = local.dhcp_start, end = local.dhcp_end }]
        }
      },
    ],
    local.ipv6_ips
  )

  forward = {
    nat = {}
  }
}
