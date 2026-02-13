output "id" {
  description = "The libvirt domain ID of the virtual machine."
  value       = libvirt_domain.vm.id
}
