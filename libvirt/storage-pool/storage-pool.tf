resource "libvirt_pool" "storage_pool" {
  count = var.pool != null ? 1 : 0

  name = var.pool.name
  type = "dir"

  target = {
    path = var.pool.path
  }
}
