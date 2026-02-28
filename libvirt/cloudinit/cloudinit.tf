locals {
  # Extract network prefix from the CIDR notation
  ipv4_cidr_prefix = split("/", var.cloudinit.ipv4_network_cidr)[1]
  ipv6_cidr_prefix = var.cloudinit.ipv6_network_cidr != null ? split("/", var.cloudinit.ipv6_network_cidr)[1] : null

  # Compute the fully qualified domain name
  fqdn = var.cloudinit.domain != null ? "${var.cloudinit.hostname}.${var.cloudinit.domain}" : var.cloudinit.hostname

  # Template rendering
  network_config = templatefile("${path.module}/templates/network-config.yaml.tftpl", {
    domain               = var.cloudinit.domain
    ipv4_cidr_prefix     = local.ipv4_cidr_prefix
    ipv4_address         = var.cloudinit.ipv4_address
    gateway_ipv4_address = var.cloudinit.gateway_ipv4_address
    ipv6_cidr_prefix     = local.ipv6_cidr_prefix
    ipv6_address         = var.cloudinit.ipv6_address
    gateway_ipv6_address = var.cloudinit.gateway_ipv6_address
  })

  meta_data = templatefile("${path.module}/templates/meta-data.yaml.tftpl", {
    hostname = var.cloudinit.hostname
  })

  user_data = templatefile("${path.module}/templates/user-data.yaml.tftpl", {
    fqdn            = local.fqdn
    hostname        = var.cloudinit.hostname
    ipv4_address    = var.cloudinit.ipv4_address
    user            = var.cloudinit.user
    ssh_public_key  = var.cloudinit.ssh_public_key
    extra_user_data = var.cloudinit.extra_user_data
  })
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "${var.cloudinit.name}-cloudinit.iso"
  meta_data      = local.meta_data
  user_data      = local.user_data
  network_config = local.network_config
}

resource "libvirt_volume" "cloudinit" {
  name = "${var.cloudinit.name}.iso"
  pool = var.cloudinit.pool

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit.path
    }
  }
}
