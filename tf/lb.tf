resource "incus_instance" "lb" {
  name = "lb"
  type = "container"
  image = "zot:apps/lb/caddy:2"

  device {
    name = "ingress-80"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:80"
      connect = "tcp:127.0.0.1:80"
    }
  }

  device {
    name = "ingress-443"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:443"
      connect = "tcp:127.0.0.1:443"
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

  config = {
    "environment.VAULT_TOKEN" = module.safehouse_access_lb.token
  }
}

module "safehouse_access_lb" {
  source = "./modules/safehouse_access"
  backend = vault_auth_backend.apps.path
  app_name = "lb"
}
