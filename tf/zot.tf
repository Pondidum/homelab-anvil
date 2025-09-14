
resource "incus_storage_volume" "zot_storage" {
  name = "zot"
  pool = "tank"
}

resource "incus_instance" "zot" {
  name = "zot"
  type = "container"
  image = "ghcr:project-zot/zot-linux-amd64:v2.1.7"

  device {
    name = "storage"
    type = "disk"
    properties = {
      path = "/var/lib/registry"
      source = incus_storage_volume.zot_storage.name
      pool = "tank"
    }
  }

  # used for seeding images externally, before the loadbalancer exists
  device {
    name = "ingress-5000"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:5000"
      connect = "tcp:127.0.0.1:5000"
    }
  }
}
