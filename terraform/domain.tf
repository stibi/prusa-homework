resource "digitalocean_domain" "app" {
  name       = var.domain
  ip_address = digitalocean_loadbalancer.app.ip
}
