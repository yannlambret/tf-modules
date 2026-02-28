variable "network" {
  description = "Configuration for the virtual network created by libvirt."

  type = object({
    # Whether the network starts automatically with the host.
    autostart = optional(bool, true)

    # Name of the libvirt network.
    name = string

    # Name of the Linux bridge interface created for this network.
    bridge = string

    # DNS search domain for the network. Resolved locally by dnsmasq.
    domain = string

    # Explicit start address for the DHCP range.
    # When null, the start address is calculated from `dhcp_offset`.
    dhcp_start = optional(string, null)

    # Explicit end address for the DHCP range.
    # When null, the end address is calculated from `dhcp_offset + dhcp_count`.
    dhcp_end = optional(string, null)

    # Host offset from the network base address for the DHCP range start.
    # Only used when `dhcp_start` is null.
    dhcp_offset = optional(number, 100)

    # Number of addresses in the DHCP range.
    # Only used when `dhcp_end` is null.
    dhcp_count = optional(number, 50)

    # List of upstream DNS forwarder addresses.
    dns_forwarders = optional(list(string), ["1.1.1.1"])

    # CIDR block for the network (e.g. "192.168.100.0/24").
    # The first usable address (.1) is assigned to the bridge as the gateway.
    ipv4_cidr = string

    # IPv6 CIDR block for the network (e.g. "fd00:1::/64").
    # When set, libvirt configures an IPv6 gateway on the bridge.
    # The first address in the range (.::1) is assigned as the gateway.
    ipv6_cidr = optional(string, null)
  })
}

variable "static_hosts" {
  description = "List of hosts statically registered in the network's DNS resolver."

  type = list(object({
    ip       = string
    hostname = string
  }))
  default = []
}
