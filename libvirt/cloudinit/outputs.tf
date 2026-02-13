output "name" {
  description = "The name of the cloud-init disk."
  value       = libvirt_cloudinit_disk.cloudinit.name
}

output "path" {
  description = "The absolute path to the cloud-init ISO in the storage pool."
  value       = libvirt_cloudinit_disk.cloudinit.path
}
