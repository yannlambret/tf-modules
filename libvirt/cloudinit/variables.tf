variable "cloudinit" {
  description = "Configuration for the cloud-init ISO disk used to initialize a VM on first boot."

  type = object({
    # Name prefix used for the cloud-init disk resource.
    name = string

    # Storage pool in which the cloud-init disk is created.
    pool = string

    # CIDR block of the VM's network (e.g. "192.168.100.0/24").
    # Used to derive the prefix length for the static network configuration.
    network_cidr = string

    # Static IPv4 address assigned to the VM.
    ipv4_address = string

    # IPv4 address of the default gateway.
    gateway_ipv4_address = string

    # Name of the OS user created on first boot.
    user = string

    # SSH public key authorized for the created user.
    ssh_public_key = string

    # Short hostname assigned to the VM.
    hostname = string

    # DNS search domain appended to the hostname to form the FQDN (e.g. "lab.local").
    # When omitted the FQDN is equal to the hostname.
    domain = optional(string)

    # Additional raw cloud-config YAML appended verbatim to the user-data section.
    extra_user_data = optional(string, "")
  })
}
