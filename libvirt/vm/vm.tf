locals {
  # The 'capacity_unit' attribute is currently buggy/unsupported in the 'libvirt_volume' resource.
  # This helper allows the module user to define disk capacity in GiB (Gibibytes).
  # See: https://github.com/dmacvicar/terraform-provider-libvirt/issues/1253
  _1GiB = 1073741824 # 1024^3
}

resource "libvirt_volume" "root_disk" {
  name     = "${var.vm.name}.${var.vm.base_image.format}"
  pool     = var.vm.pool
  capacity = var.vm.disk_capacity * local._1GiB

  target = {
    format = {
      type = var.vm.base_image.format
    }
  }

  backing_store = {
    path = var.vm.base_image.path

    format = {
      type = var.vm.base_image.format
    }
  }
}

resource "libvirt_domain" "vm" {
  type        = "kvm"
  name        = var.vm.name
  vcpu        = var.vm.vcpu
  memory      = var.vm.memory
  memory_unit = "MiB"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"

    # Let libvirt resolve the UEFI firmware automatically from the host's
    # firmware descriptor files (/usr/share/qemu/firmware/*.json).
    firmware = "efi"

    boot_devices = [
      {
        dev = "hd"
      },
    ]
  }

  features = {
    acpi = true
    apic = {
      eoi = "on"
    }
  }

  devices = {

    consoles = [
      {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
      },
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "0.0.0.0"
        }
      }
    ]

    disks = [
      {
        device   = "cdrom"
        readonly = true
        source = {
          file = {
            file = var.vm.cloudinit_path
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      },
      {
        source = {
          file = {
            file = libvirt_volume.root_disk.path
          }
        }
        backing_store = {
          source = {
            file = {
              file = var.vm.base_image.path
            }
          }
          format = {
            type = var.vm.base_image.format
          }
        }
        driver = {
          type = var.vm.base_image.format
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
    ]
    interfaces = [
      {
        # If static_ip_address is null, wait for a DHCP lease before reporting ready.
        wait_for_lease = var.vm.static_ip_address == null
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = var.vm.network
          }
        }
      },
    ]
  }
}
