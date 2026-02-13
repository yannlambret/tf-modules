# tf-modules

A collection of reusable Terraform modules for personal infrastructure.

## Modules

### libvirt

Modules for managing KVM/QEMU virtual machines through [libvirt](https://libvirt.org/), targeting a single local host.
Designed to spin up lightweight lab environments (e.g. Kubernetes clusters) using cloud images and cloud-init.

| Module | Description |
|--------|-------------|
| [libvirt/network](libvirt/network/) | Virtual network with NAT, DHCP, and a local DNS resolver |
| [libvirt/storage-pool](libvirt/storage-pool/) | Storage pool and base image management |
| [libvirt/cloudinit](libvirt/cloudinit/) | Cloud-init ISO disk for VM first-boot configuration |
| [libvirt/vm](libvirt/vm/) | KVM virtual machine (UEFI, Q35, virtio) |

## Requirements

- Terraform >= 1.8
- [dmacvicar/libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest) >= 0.9.2
- A reachable libvirt daemon (`qemu:///system` or remote)

## Usage

Each module is consumed directly via its Git source path. Modules are versioned independently using tags of the form
`libvirt/<module>/vX.Y.Z`:

```hcl
module "network" {
  source = "git::https://github.com/yannlambret/tf-modules.git//libvirt/network?ref=libvirt/network/v0.1.0"

  network = {
    name   = "k8s-lab"
    bridge = "virbr-k8s"
    cidr   = "192.168.100.0/24"
    domain = "lab.local"
  }
}
```

Refer to each module's `README.md` for the full interface and usage examples.

## License

MIT
