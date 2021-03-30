resource "digitalocean_droplet" "app_server" {
  # rename na homework
  name   = "prusa-task-app-server-01"
  image  = var.app_server_image
  size   = var.app_server_size
  region = var.region
  ssh_keys = [
    var.default_ssh_key_fingerprint
  ]
  tags = ["app-server"]
}
