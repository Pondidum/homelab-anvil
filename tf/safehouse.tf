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

  device {
    name = "ingress-8200"
    type = "proxy"
    properties = {
      listen = "tcp:0.0.0.0:8200"
      connect = "tcp:127.0.0.1:8200"
    }
  }
}


resource "vault_mount" "kv" {
  path = "kv"
  type = "kv-v2"
  description = "generic secrets"
  options = {
    version = "2"
    type = "kv-v2"
  }

  depends_on = [
    incus_instance.safehouse
  ]
}

resource "vault_auth_backend" "apps" {
  type = "approle"

  depends_on = [
    incus_instance.safehouse
  ]
}

resource "vault_policy" "apps" {
  name = "app"
  policy = <<EOT
path "kv/data/apps/{{identity.entity.aliases.${vault_auth_backend.apps.accessor}.metadata.role_name}}/*" {
  capabilities = ["create", "update", "patch", "read", "delete", "list"]
}

path "kv/data/external/*" {
  capabilities = ["create", "update", "patch", "read", "delete", "list"]
}

path "kv/metadata/*" {
  capabilities = ["read", "list"]
}
EOT
}
