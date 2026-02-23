variable "vm" {
  description = "Configuration for the virtual machine instance."

  type = object({
    # Name of the libvirt domain and root disk volume.
    name = string

    # Memory allocated to the VM, in MiB.
    memory = number

    # Number of virtual CPUs.
    vcpu = number

    # Storage pool in which the root disk volume is created.
    pool = string

    # Size of the root disk, in GiB.
    disk_capacity = number

    # Absolute path to the cloud-init ISO.
    cloudinit_path = string

    # Name of the libvirt network to attach the VM to.
    network = string

    # Static IPv4 address of the VM. When set, Terraform skips waiting for a
    # DHCP lease after boot.
    static_ipv4_address = optional(string, null)

    # Base disk image used as the copy-on-write backing store for the root disk.
    base_image = object({
      # Absolute path to the base image volume.
      path = string

      # Disk image format (e.g. "qcow2").
      format = string
    })
  })
}
