# network

Creates a libvirt virtual network with NAT forwarding, DHCP, and a local DNS resolver (dnsmasq). The gateway address
is automatically set to the first host in the CIDR block. DHCP ranges can be specified explicitly or derived from
configurable offsets.

## Usage

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name   = "k8s-lab"
    bridge = "virbr-k8s"
    cidr   = "192.168.100.0/24"
    domain = "lab.local"
  }
}
```

### Static DNS registrations

Use `static_hosts` to pre-register VM hostnames in dnsmasq:

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name   = "k8s-lab"
    bridge = "virbr-k8s"
    cidr   = "192.168.100.0/24"
    domain = "lab.local"
  }

  static_hosts = [
    { ip = "192.168.100.10", hostname = "node-1" },
    { ip = "192.168.100.11", hostname = "node-2" },
    { ip = "192.168.100.12", hostname = "node-3" },
  ]
}
```

### Custom DHCP range and DNS forwarders

```hcl
module "network" {
  source = "./libvirt/network"

  network = {
    name           = "k8s-lab"
    bridge         = "virbr-k8s"
    cidr           = "192.168.100.0/24"
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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `network.name` | Name of the libvirt network. | `string` | — | yes |
| `network.bridge` | Name of the Linux bridge interface created for this network. | `string` | — | yes |
| `network.cidr` | CIDR block for the network (e.g. `192.168.100.0/24`). The first usable address (`.1`) is assigned to the bridge as the gateway. | `string` | — | yes |
| `network.domain` | DNS search domain resolved locally by dnsmasq. | `string` | — | yes |
| `network.autostart` | Whether the network starts automatically with the host. | `bool` | `true` | no |
| `network.dhcp_start` | Explicit start address of the DHCP range. When null, derived from `dhcp_offset`. | `string` | `null` | no |
| `network.dhcp_end` | Explicit end address of the DHCP range. When null, derived from `dhcp_offset + dhcp_count`. | `string` | `null` | no |
| `network.dhcp_offset` | Host offset from the network base address for the DHCP range start. Used only when `dhcp_start` is null. | `number` | `100` | no |
| `network.dhcp_count` | Number of addresses in the DHCP range. Used only when `dhcp_end` is null. | `number` | `50` | no |
| `network.dns_forwarders` | List of upstream DNS forwarder addresses. | `list(string)` | `["8.8.8.8"]` | no |
| `static_hosts` | List of hosts statically registered in the network's DNS resolver. | `list(object({ ip = string, hostname = string }))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the libvirt network. |
| `bridge` | The name of the Linux bridge interface backing this network. |
| `cidr` | The CIDR block of the network. |
| `gateway_ipv4_address` | The IPv4 address of the gateway (first host in the CIDR block). |
| `domain` | The DNS search domain associated with the network. |
