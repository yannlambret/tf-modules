# network

Creates a libvirt virtual network with NAT forwarding, DHCP, and a local DNS resolver (dnsmasq). The gateway address
is automatically set to the first host in the CIDR block. DHCP ranges can be specified explicitly or derived from
configurable offsets. An optional IPv6 prefix can be added to configure a dual-stack bridge.

## Usage

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name      = "k8s-lab"
    bridge    = "virbr-k8s"
    ipv4_cidr = "192.168.100.0/24"
    domain    = "lab.local"
  }
}
```

### Static DNS registrations

Use `static_hosts` to pre-register VM hostnames in dnsmasq:

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name      = "k8s-lab"
    bridge    = "virbr-k8s"
    ipv4_cidr = "192.168.100.0/24"
    domain    = "lab.local"
  }

  static_hosts = [
    { ipv4 = "192.168.100.10", hostname = "node-1" },
    { ipv4 = "192.168.100.11", hostname = "node-2" },
    { ipv4 = "192.168.100.12", hostname = "node-3" },
  ]
}
```

### With IPv6

Set `ipv6_cidr` to add a dual-stack bridge. libvirt will configure the IPv6 gateway on the bridge and handle Router
Advertisements via dnsmasq. Use a ULA prefix (`fd00::/8`) for lab environments:

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name      = "k8s-lab"
    bridge    = "virbr-k8s"
    ipv4_cidr = "192.168.100.0/24"
    ipv6_cidr = "fd00:1::/64"
    domain    = "lab.local"
  }
  
  static_hosts = [
    { ipv4 = "192.168.100.10", ipv6 = "fd00:1::a", hostname = "node-1" },
    { ipv4 = "192.168.100.11", ipv6 = "fd00:1::b", hostname = "node-2" },
    { ipv4 = "192.168.100.12", ipv6 = "fd00:1::c", hostname = "node-3" },
  ]
}
```

> **Host sysctl prerequisite.** When `ipv6_cidr` is set, libvirt enables IPv6 forwarding on the host to route traffic
> through the bridge. If the host's upstream interface receives its own IPv6 address via SLAAC (Router Advertisements),
> the kernel would normally flush those autoconfigured routes the moment forwarding is enabled — and libvirt refuses to
> start the network rather than silently break host connectivity. The fix is to set `accept_ra=2` on the upstream
> interface, which keeps RA processing active even when forwarding is on:
>
> ```bash
> # Apply immediately
> sudo sysctl -w net.ipv6.conf.all.accept_ra=2
> sudo sysctl -w net.ipv6.conf.<iface>.accept_ra=2
>
> # Persist across reboots
> echo -e "net.ipv6.conf.all.accept_ra = 2\nnet.ipv6.conf.<iface>.accept_ra = 2" \
>   | sudo tee /etc/sysctl.d/99-ipv6-accept-ra.conf
> ```
>
> Replace `<iface>` with the host's upstream interface name (e.g. `enp5s0`). This is only needed when the host itself
> has a SLAAC-configured IPv6 address; hosts with static IPv6 or no IPv6 at all are unaffected.

### Custom DHCP range and DNS forwarders

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name           = "k8s-lab"
    bridge         = "virbr-k8s"
    ipv4_cidr      = "192.168.100.0/24"
    domain         = "lab.local"
    dhcp_start     = "192.168.100.200"
    dhcp_end       = "192.168.100.250"
    dns_forwarders = ["1.1.1.1", "1.0.0.1"]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| [dmacvicar/libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest) | >= 0.9.2 |

## Inputs

| Name                     | Description | Type | Default | Required |
|--------------------------|-------------|------|---------|:--------:|
| `network.name`           | Name of the libvirt network. | `string` | — | yes |
| `network.bridge`         | Name of the Linux bridge interface created for this network. | `string` | — | yes |
| `network.ipv4_cidr`      | CIDR block for the network (e.g. `192.168.100.0/24`). The first usable address (`.1`) is assigned to the bridge as the gateway. | `string` | — | yes |
| `network.domain`         | DNS search domain resolved locally by dnsmasq. | `string` | — | yes |
| `network.autostart`      | Whether the network starts automatically with the host. | `bool` | `true` | no |
| `network.dhcp_start`     | Explicit start address of the DHCP range. When null, derived from `dhcp_offset`. | `string` | `null` | no |
| `network.dhcp_end`       | Explicit end address of the DHCP range. When null, derived from `dhcp_offset + dhcp_count`. | `string` | `null` | no |
| `network.dhcp_offset`    | Host offset from the network base address for the DHCP range start. Used only when `dhcp_start` is null. | `number` | `100` | no |
| `network.dhcp_count`     | Number of addresses in the DHCP range. Used only when `dhcp_end` is null. | `number` | `50` | no |
| `network.dns_forwarders` | List of upstream DNS forwarder addresses. | `list(string)` | `["1.1.1.1"]` | no |
| `network.ipv6_cidr`      | IPv6 CIDR block for the network (e.g. `fd00:1::/64`). When set, libvirt configures an IPv6 gateway on the bridge. The first address (`::1`) is assigned as the gateway. | `string` | `null` | no |
| `static_hosts`           | List of hosts statically registered in the network's DNS resolver. Each entry creates an A record; adding `ipv6` also creates a AAAA record for the same hostname. | `list(object({ ip = string, ipv6 = optional(string), hostname = string }))` | `[]` | no |

## Outputs

| Name                   | Description                                                                              |
|------------------------|------------------------------------------------------------------------------------------|
| `name`                 | The name of the libvirt network.                                                         |
| `bridge`               | The name of the Linux bridge interface backing this network.                             |
| `domain`               | The DNS search domain associated with the network.                                       |
| `ipv4_cidr`            | The CIDR block of the IPv4 network.                                                      |
| `ipv6_cidr`            | The IPv6 CIDR block of the network, or `null` if IPv6 is not configured.                 |
| `gateway_ipv4_address` | The IPv4 address of the gateway (first host in the IPv4 CIDR block).                     |
| `gateway_ipv6_address` | The IPv6 address of the gateway (first host in the IPv6 CIDR block), or `null` if IPv6 is not configured. |
