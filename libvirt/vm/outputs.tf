output "id" {
  description = "The libvirt domain ID of the virtual machine."
  value       = libvirt_domain.vm.id
}

output "ipv4_address" {
  description = "The IPv4 address of the VM. Returns the statically configured address when `static_ipv4_address` is set, null for DHCP-assigned VMs."
  value       = var.vm.static_ipv4_address
}
