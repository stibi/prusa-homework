resource "digitalocean_droplet" "app_server" {
  count = var.app_servers_count

  name   = format("%s-app-server-%02s", var.project_name, count.index + 1)
  image  = var.app_server_image
  size   = var.app_server_size
  region = var.region
  ssh_keys = [
    var.default_ssh_key_fingerprint
  ]
  # the first (with index 0) droplet is both app and db server, all others are only app servers
  # poor man's inventory management
  tags = count.index == 0 ? ["app-server", "db-server"] : ["app-server"]
}
