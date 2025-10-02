terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
      version = "0.5.1"
    }

    vault = {
      source = "hashicorp/vault"
      version = "5.3.0"
    }
  }
}

provider "incus" {
  remote {
    name = "anvil"
    scheme = "https"
    address = "anvil"
    port = 8443
    default = true
  }
  accept_remote_certificate = true
  generate_client_certificates = true
  config_dir = "./incus_conf" 
}

provider "vault" {
  address = "https://anvil:8200"
}
