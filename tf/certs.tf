resource "incus_storage_volume" "certificates" {
  name = "certificates"
  pool = "tank"
}

# currently there doesn't seem to be a way to add a file to the volume through tf.
# so instead I mounted the pool with zfs, and then copied my anvil certificate and key into it.
# this was then visible to a test container below.
resource "incus_instance" "test" {
  name = "test"
  type = "container"
  image = "images:debian/bookworm"

  device {
    name = "certificates"
    type = "disk"
    properties = {
      path = "/etc/anvil/certificates"
      source = incus_storage_volume.certificates.name
      pool = "tank"
    }
  }

}
