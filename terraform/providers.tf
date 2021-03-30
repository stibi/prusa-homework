provider "digitalocean" {
  # TODO mozna radeji env var?
  token = chomp(file("~/.config/digital-ocean/token"))
}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.7"
    }
  }
}
