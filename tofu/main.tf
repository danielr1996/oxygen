resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = file("../.ssh/key.pub")
}

module "controller" {
  source = "./hetzner_nodegroup"
  location = "nbg1"
  role = "single"
  server_type = "cax21"
  size = 1
  sshkey = hcloud_ssh_key.default.id
}

module "cluster" {
  source = "./k0s_cluster"
  # TODO: make templateable
  name   = "oxygen"
  nodes  = concat(
    module.controller.nodes,
  )
  extensions = local.hetzner_extensions
}

output "k0sctl" {
  value = module.cluster.k0sctl
}