terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
      version = "0.4.0"
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
