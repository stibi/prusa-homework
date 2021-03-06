variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "default_ssh_key_fingerprint" {
  type = string
}

variable "app_server_image" {
  type = string
}

variable "app_server_size" {
  type = string
}

variable "domain" {
  type = string
}

variable "app_servers_count" {
  type        = number
  default     = 1
  description = "How many app servers to deploy"
}

variable "ssh_allowed_addresses" {
  type        = list(any)
  default     = []
  description = "List of ip addresses allowed to ssh to servers"
}
