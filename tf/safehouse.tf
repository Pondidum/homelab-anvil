resource "incus_storage_volume" "safehouse_storage" {
  name = "safehouse"
  pool = "tank"
}

resource "incus_instance" "safehouse" {
  name = "safehouse"
  type = "container"
  image = "zot:apps/safehouse/safehouse:4"

  config = {
    "oci.entrypoint" = "/bin/entrypoint.sh server"
  }

  device {
    name = "storage"
    type = "disk"
    properties = {
      path = "/safehouse"
      source = incus_storage_volume.safehouse_storage.name
      pool = "tank"
    }
  }

  device {
    name = "certificates"
    type = "disk"
    properties = {
      path = "/etc/anvil/certificates"
      source = incus_storage_volume.certificates.name
      pool = "tank"
    }
  }

  # used for seeding images externally, before the loadbalancer exists
  device {
    name = "ingress-8200"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:8200"
      connect = "tcp:127.0.0.1:8200"
    }
  }
}
