# rename, public je z doc
resource "digitalocean_loadbalancer" "public" {
  name   = "prusa-homework"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 5000
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.app_server.id]
}
