output "nodes" {
  value = [
    for node in hcloud_server.nodegroup :{
      role    = var.role
      address = node.ipv4_address,
      user    = "root",
      port    = 22,
      sshkey = "../.ssh/key"
    }
  ]
}

variable "size" {
  type = number
}
variable "name" {
  type    = string
  default = ""
}

variable "server_type" {
  type = string
}
variable "location" {
  type = string
}
variable "role" {
  type = string
}

variable "sshkey" {
}

resource "hcloud_server" "nodegroup" {
  count       = var.size
  name        = "${var.role}-${var.name}-${count.index}"
  server_type = var.server_type
  location    = var.location
  image       = "ubuntu-24.04"
  ssh_keys    = [var.sshkey]
}



resource "terraform_data" "updatehostkeys" {
  provisioner "local-exec" {
    command     = <<-EOF
      touch $HOME/.ssh/known_hosts
      %{ for ip in hcloud_server.nodegroup[*].ipv4_address }
      ssh-keygen -R ${ip}
      ssh-keyscan -H ${ip} >> $HOME/.ssh/known_hosts
      %{ endfor }
      exit 0
    EOF
    interpreter = ["bash", "-c"]
  }
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }
  }
}