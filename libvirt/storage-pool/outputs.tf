output "name" {
  description = "The name of the storage pool (or \"default\" when no custom pool was created)."
  value       = var.pool != null ? libvirt_pool.storage_pool[0].name : "default"
}

output "base_images" {
  description = "Map of downloaded base images keyed by name, each containing id, name, path, and format."
  value = {
    for img in var.base_images :
    img.name => {
      id     = libvirt_volume.base_images[img.name].id
      name   = libvirt_volume.base_images[img.name].name
      path   = libvirt_volume.base_images[img.name].path
      format = img.format
    }
  }
}
