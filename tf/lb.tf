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
    "environment.VAULT_TOKEN" =vault_approle_auth_backend_login.lb.client_token
  }
}


resource "vault_approle_auth_backend_role" "lb" {
  backend = vault_auth_backend.apps.path
  role_name = "lb"
  token_policies = [ "default" , vault_policy.apps.name ]
}

resource "vault_approle_auth_backend_role_secret_id" "lb" {
  backend = vault_auth_backend.apps.path
  role_name = vault_approle_auth_backend_role.lb.role_name
}

resource "vault_approle_auth_backend_login" "lb" {
  backend = vault_auth_backend.apps.path
  role_id = vault_approle_auth_backend_role.lb.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.lb.secret_id
}
