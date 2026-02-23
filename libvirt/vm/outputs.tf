output "id" {
  description = "The libvirt domain ID of the virtual machine."
  value       = libvirt_domain.vm.id
}

output "host_ipv4_address" {
  description = "The IPv4 address of the VM. Returns the statically configured address when `static_ip_address` is set, null for DHCP-assigned VMs."
  value       = var.vm.static_ip_address
}
