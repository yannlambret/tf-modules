# Base images, downloaded once

locals {
  # If a custom pool was created, use it. Otherwise, use the default libvirt pool.
  pool = var.pool != null ? libvirt_pool.storage_pool[0].name : "default"
}

resource "libvirt_volume" "base_images" {
  for_each = { for item in var.base_images : item.name => item }

  pool = local.pool
  name = each.value.name

  create = {
    content = {
      url = each.value.source
    }
  }
}
