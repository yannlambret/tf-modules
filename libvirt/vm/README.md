# vm

Creates a KVM virtual machine using UEFI/OVMF firmware on a Q35 machine type. The VM boots from a copy-on-write root
disk backed by a base image, with a cloud-init ISO mounted as a CDROM for first-boot configuration. A VNC console and a
serial PTY are always configured for out-of-band access.

UEFI firmware is resolved automatically by libvirt using the host's firmware descriptor files
(`/usr/share/qemu/firmware/*.json`), so no distribution-specific paths need to be configured.

> **Note on disk capacity**: the `capacity_unit` attribute is currently broken in the libvirt provider. Disk capacity
must be expressed in bytes. The module handles the GiB → bytes conversion internally, so `disk_capacity` is specified
in GiB. See [provider issue #1253](https://github.com/dmacvicar/terraform-provider-libvirt/issues/1253).

## Usage

```hcl
module "vm" {
  source = "./libvirt/vm"

  vm = {
    name           = "node-1"
    vcpu           = 2
    memory         = 2048 # MiB
    disk_capacity  = 20   # GiB
    pool           = module.storage.name
    cloudinit_path = module.cloudinit.path
    network        = module.network.name

    base_image = {
      path   = module.storage.base_images["debian-12-base.qcow2"].path
      format = module.storage.base_images["debian-12-base.qcow2"].format
    }
  }
}
```

### Static IP address

When the VM is configured with a static IP (via cloud-init), set `static_ip_address` so that Terraform does not wait
for a DHCP lease:

```hcl
module "vm" {
  source = "./libvirt/vm"

  vm = {
    # ...
    static_ip_address = "192.168.100.10"
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
| `vm.name` | Name of the libvirt domain and root disk volume. | `string` | — | yes |
| `vm.memory` | Memory allocated to the VM in MiB. | `number` | — | yes |
| `vm.vcpu` | Number of virtual CPUs. | `number` | — | yes |
| `vm.pool` | Storage pool in which the root disk volume is created. | `string` | — | yes |
| `vm.disk_capacity` | Size of the root disk in GiB. | `number` | — | yes |
| `vm.cloudinit_path` | Absolute path to the cloud-init ISO disk. Typically sourced from the `cloudinit` module output. | `string` | — | yes |
| `vm.network` | Name of the libvirt network to attach the VM to. | `string` | — | yes |
| `vm.base_image.path` | Absolute path to the base image volume used as the CoW backing store. | `string` | — | yes |
| `vm.base_image.format` | Format of the base image (e.g. `qcow2`). | `string` | — | yes |
| `vm.static_ip_address` | Static IPv4 address of the VM. When set, Terraform will not wait for a DHCP lease after boot. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The libvirt domain ID of the virtual machine. |
