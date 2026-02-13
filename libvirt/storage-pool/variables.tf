variable "pool" {
  description = "Optional libvirt storage pool to create. When null, base images are downloaded into the default libvirt pool."

  type = object({
    # Name of the storage pool.
    name = string

    # Absolute path on the host filesystem used as the pool directory.
    path = string
  })

  default = null
}

variable "base_images" {
  description = "List of base disk images to download into the storage pool. Images are downloaded once and reused as backing stores for VM root disks."

  type = list(object({
    # Unique name for the volume (e.g. "debian-12-base.qcow2").
    name = string

    # URL from which the image is downloaded.
    source = string

    # Disk image format (e.g. "qcow2", "raw").
    format = string
  }))

  default = []
}
