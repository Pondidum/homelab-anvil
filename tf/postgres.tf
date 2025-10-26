resource "incus_storage_volume" "postgres_storage" {
  name = "postgres"
  pool = "tank"
}

resource "incus_instance" "postgres" {
  name = "postgres"
  type = "container"
  image = "docker:postgres:18"


  device {
    name = "storage"
    type = "disk"
    properties = {
      path = "/var/lib/postgresql"
      source = incus_storage_volume.postgres_storage.name
      pool = "tank"
    }
  }
  
  # allow direct connections from outside for testing
  device {
    name = "ingress-5432"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:5432"
      connect = "tcp:127.0.0.1:5432"
    }
  }
  
  config = {
    # "environment.VAULT_TOKEN" = module.safehouse_access_postgres.token
    "environment.POSTGRES_USER" = data.vault_kv_secret_v2.postgres_root.data["user"]
    "environment.POSTGRES_PASSWORD" = data.vault_kv_secret_v2.postgres_root.data["password"]
  }
}

module "postgres_safehouse_access" {
  source = "./modules/safehouse_access"
  backend = vault_auth_backend.apps.path
  app_name = "postgres"
}

data "vault_kv_secret_v2" "postgres_root" {
  mount = "kv"
  name = "apps/postgres/super"
}
