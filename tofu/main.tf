resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = file("../.ssh/key.pub")
}

module "controller" {
  source = "./hetzner_nodegroup"
  location = "nbg1"
  role = "controller"
  server_type = "cax11"
  size = 1
  sshkey = hcloud_ssh_key.default.id
}

module "worker-sm" {
  source = "./hetzner_nodegroup"
  location = "nbg1"
  name = "sm"
  role = "worker"
  server_type = "cax11"
  size = 1
  sshkey = hcloud_ssh_key.default.id
}

module "worker-lg" {
  source = "./hetzner_nodegroup"
  location = "nbg1"
  name = "lg"
  role = "worker"
  server_type = "cax31"
  size = 1
  sshkey = hcloud_ssh_key.default.id
}

module "cluster" {
  source = "./k0s_cluster"
  # TODO: make templateable
  name   = "oxygen"
  nodes  = concat(
    module.controller.nodes,
    module.worker-lg.nodes,
    module.worker-sm.nodes
  )
  extensions = local.hetzner_extensions
}

output "k0sctl" {
  value = module.cluster.k0sctl
}