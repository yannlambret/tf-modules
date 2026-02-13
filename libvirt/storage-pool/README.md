# storage-pool

Manages a libvirt storage pool and downloads base disk images into it. Base images are downloaded once from a URL and
stored as libvirt volumes, ready to be used as copy-on-write (CoW) backing stores for VM root disks.

When `pool` is null no storage pool is created and images are downloaded into the libvirt default pool.

## Usage

### Download images into the default pool

```hcl
module "storage" {
  source = "./libvirt/storage-pool"

  base_images = [
    {
      name   = "debian-12-base.qcow2"
      source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
      format = "qcow2"
    },
  ]
}
```

### Create a dedicated pool and download images into it

```hcl
module "storage" {
  source = "./libvirt/storage-pool"

  pool = {
    name = "k8s-lab"
    path = "/srv/libvirt/k8s-lab"
  }

  base_images = [
    {
      name   = "debian-12-base.qcow2"
      source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
      format = "qcow2"
    },
    {
      name   = "ubuntu-24.04-base.qcow2"
      source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
      format = "qcow2"
    },
  ]
}
```

### Referencing images in the `vm` module

```hcl
module "vm" {
  source = "./libvirt/vm"

  vm = {
    # ...
    pool = module.storage.name
    base_image = {
      path   = module.storage.base_images["debian-12-base.qcow2"].path
      format = module.storage.base_images["debian-12-base.qcow2"].format
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| [dmacvicar/libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest) | >= 0.9.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `pool` | Optional libvirt storage pool to create. When null, base images are downloaded into the default libvirt pool. | `object({ name = string, path = string })` | `null` | no |
| `pool.name` | Name of the storage pool. | `string` | — | yes (if `pool` is set) |
| `pool.path` | Absolute path on the host filesystem used as the pool directory. | `string` | — | yes (if `pool` is set) |
| `base_images` | List of base disk images to download. Images are fetched from their `source` URL and stored as libvirt volumes. | `list(object({...}))` | `[]` | no |
| `base_images[].name` | Unique name for the volume (e.g. `debian-12-base.qcow2`). | `string` | — | yes |
| `base_images[].source` | URL from which the image is downloaded. | `string` | — | yes |
| `base_images[].format` | Disk image format (e.g. `qcow2`, `raw`). | `string` | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the storage pool, or `"default"` when no custom pool was created. |
| `base_images` | Map of downloaded base images keyed by name. Each entry contains `id`, `name`, `path`, and `format`. |
