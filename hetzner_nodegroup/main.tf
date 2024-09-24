output "nodes" {
  value = [
    for node in hcloud_server.nodegroup :{
      role    = var.role
      address = node.ipv4_address,
      user    = "root",
      port    = 22,
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
variable "image" {
  type = string
}
variable "role" {
  type = string
}

variable "ssh_key" {

}

resource "hcloud_server" "nodegroup" {
  count       = var.size
  name        = "${var.role}-${var.name}-${count.index}"
  server_type = var.server_type
  location    = var.location
  image       = var.image
  ssh_keys    = [var.ssh_key]
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