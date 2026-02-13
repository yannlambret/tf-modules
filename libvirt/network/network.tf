locals {
  netmask              = cidrnetmask(var.network.cidr)
  gateway_ipv4_address = cidrhost(var.network.cidr, 1)

  # Use the variable if provided, otherwise calculate from offset
  dhcp_start = coalesce(var.network.dhcp_start, cidrhost(var.network.cidr, var.network.dhcp_offset))
  dhcp_end   = coalesce(var.network.dhcp_end, cidrhost(var.network.cidr, var.network.dhcp_offset + var.network.dhcp_count))

  # NAT always covers the full usable range
  nat_start = cidrhost(var.network.cidr, 2)
  nat_end   = cidrhost(var.network.cidr, -2)
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

    host = [
      for h in var.static_hosts : {
        ip        = h.ip
        hostnames = [{ hostname = h.hostname }]
      }
    ]
  }

  ips = [
    {
      address = local.gateway_ipv4_address
      netmask = local.netmask

      dhcp = {
        enabled = true
        ranges = [
          {
            start = local.dhcp_start
            end   = local.dhcp_end
          },
        ]
      }
    },
  ]

  forward = {
    nat = {
      addresses = [
        {
          start = local.nat_start
          end   = local.nat_end
        },
      ]
    }
  }
}
