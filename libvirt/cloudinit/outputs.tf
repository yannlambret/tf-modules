output "volume_path" {
  description = "The absolute path to the cloud-init volume in the storage pool."
  value       = libvirt_volume.cloudinit.path
}
