# cloudinit

Creates a [cloud-init](https://cloud-init.io/) ISO disk for VM initialization. The generated ISO configures a static
network interface via Netplan (IPv4-only or dual-stack IPv4+IPv6), sets the hostname and FQDN, creates a sudo-enabled
user with SSH public key access, and optionally appends extra cloud-config directives.

## Usage

```hcl
module "cloudinit" {
  source = "./libvirt/cloudinit"

  cloudinit = {
    name                 = "node-1"
    hostname             = "node-1"
    pool                 = "default"
    ipv4_network_cidr    = "192.168.100.0/24"
    ipv4_address         = "192.168.100.10"
    gateway_ipv4_address = "192.168.100.1"
    domain               = "lab.local"
    user                 = "ubuntu"
    ssh_public_key       = file("~/.ssh/id_ed25519.pub")
  }
}
```

### With static IPv6

Pass `ipv6_network_cidr`, `ipv6_address`, and `gateway_ipv6_address` together to configure a static IPv6 address on
the interface. DHCPv6 and Router Advertisement acceptance are disabled, which is required for nodes that enable IPv6
forwarding (e.g. Kubernetes).

```hcl
module "cloudinit" {
  source = "./libvirt/cloudinit"

  cloudinit = {
    name                 = "node-1"
    hostname             = "node-1"
    pool                 = "default"
    ipv4_network_cidr    = module.network.ipv4_cidr
    ipv4_address         = "192.168.100.10"
    gateway_ipv4_address = module.network.gateway_ipv4_address
    ipv6_network_cidr    = module.network.ipv6_cidr
    ipv6_address         = "fd00:1::10"
    gateway_ipv6_address = module.network.gateway_ipv6_address
    domain               = "lab.local"
    user                 = "ubuntu"
    ssh_public_key       = file("~/.ssh/id_ed25519.pub")
  }
}
```

### Passing extra cloud-config

Use `extra_user_data` to append raw cloud-config YAML, for example to install packages on first boot:

```hcl
module "cloudinit" {
  source = "./libvirt/cloudinit"

  cloudinit = {
    # ... (required fields as above)
    extra_user_data = <<-EOF
      packages:
        - curl
        - vim
      runcmd:
        - systemctl enable --now qemu-guest-agent
    EOF
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| [dmacvicar/libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest) | >= 0.9.2 |

## Inputs

| Name                             | Description                                                                                                                           | Type | Default | Required |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| `cloudinit.name`                 | Name prefix for the cloud-init disk resources.                                                                                        | `string` | — | yes |
| `cloudinit.pool`                 | Storage pool in which the cloud-init ISO is created.                                                                                  | `string` | — | yes |
| `cloudinit.ipv4_network_cidr`    | CIDR block of the VM's IPv4 network (e.g. `192.168.100.0/24`). Used to derive the prefix length for the static network configuration. | `string` | — | yes |
| `cloudinit.ipv4_address`         | Static IPv4 address assigned to the VM.                                                                                               | `string` | — | yes |
| `cloudinit.gateway_ipv4_address` | IPv4 address of the default gateway.                                                                                                  | `string` | — | yes |
| `cloudinit.user`                 | Name of the OS user created on first boot.                                                                                            | `string` | — | yes |
| `cloudinit.ssh_public_key`       | SSH public key authorized for the created user.                                                                                       | `string` | — | yes |
| `cloudinit.hostname`             | Short hostname assigned to the VM.                                                                                                    | `string` | — | yes |
| `cloudinit.ipv6_network_cidr`    | IPv6 CIDR block of the VM's network (e.g. `fd00:1::/64`). Used to derive the prefix length. Must be set together with `ipv6_address` and `gateway_ipv6_address`. | `string` | `null` | no |
| `cloudinit.ipv6_address`         | Static IPv6 address assigned to the VM. Must be set together with `ipv6_network_cidr` and `gateway_ipv6_address`.                                                | `string` | `null` | no |
| `cloudinit.gateway_ipv6_address` | IPv6 address of the default gateway. Must be set together with `ipv6_network_cidr` and `ipv6_address`.                                                           | `string` | `null` | no |
| `cloudinit.domain`               | DNS search domain appended to the hostname to form the FQDN (e.g. `lab.local`). When omitted the FQDN equals the hostname.                                       | `string` | `null` | no |
| `cloudinit.extra_user_data`      | Additional raw cloud-config YAML appended verbatim to the `user-data` section.                                                                                   | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the cloud-init disk. |
| `path` | The absolute path to the cloud-init ISO in the storage pool. |
