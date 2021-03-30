resource "digitalocean_certificate" "le_cert" {
  name    = "le-${var.domain}"
  type    = "lets_encrypt"
  domains = [var.domain]
}

# rename, public je z doc
resource "digitalocean_loadbalancer" "public" {
  name                   = "prusa-homework"
  region                 = var.region
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 5000
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 5000
    target_protocol = "http"

    certificate_name = digitalocean_certificate.le_cert.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  # TODO taky bych mohl pouzit droplet_tag
  droplet_ids = [digitalocean_droplet.app_server.id]
}
