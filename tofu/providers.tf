terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }
  }
}

variable "hcloud" {
  type = object({
    token = string
  })
}

provider "hcloud" {
  token = var.hcloud.token
}