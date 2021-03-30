resource "digitalocean_domain" "app" {
  name       = "devopsakuprusi.cz"
  ip_address = digitalocean_loadbalancer.public.ip
}
