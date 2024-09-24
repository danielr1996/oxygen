resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = file(".ssh/key.pub")
}

provider "hcloud" {
  token = var.hcloud.token
}