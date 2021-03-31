resource "digitalocean_droplet" "app_server" {
  count = var.app_servers_count

  name   = format("%s-app-server-%02s", var.project_name, count.index + 1)
  image  = var.app_server_image
  size   = var.app_server_size
  region = var.region
  ssh_keys = [
    var.default_ssh_key_fingerprint
  ]
  tags = ["app-server"]
}
