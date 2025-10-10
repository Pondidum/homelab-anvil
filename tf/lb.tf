resource "incus_instance" "lb" {
  name = "lb"
  type = "container"
  image = "zot:caddy:2.10.2-alpine"

  device {
    name = "ingress-80"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:80"
      connect = "tcp:127.0.0.1:80"
    }
  }

  file {
    content = file("./caddyfile")
    target_path = "/etc/caddy/Caddyfile"
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
