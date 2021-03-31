resource "digitalocean_certificate" "le_cert" {
  name    = "le-${var.domain}"
  type    = "lets_encrypt"
  domains = [var.domain]
}

# rename, public je z doc
resource "digitalocean_loadbalancer" "public" {
  name                   = var.project_name
  region                 = var.region
  redirect_http_to_https = true
  droplet_tag            = "app-server"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 4000
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 4000
    target_protocol = "http"

    certificate_name = digitalocean_certificate.le_cert.name
  }

  healthcheck {
    protocol = "http"
    port     = 4000
    path     = "/status"
  }
}
