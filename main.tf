module "controller" {
  source = "./hetzner_nodegroup"
  image  = "ubuntu-24.04"
  location = "nbg1"
  role = "controller"
  server_type = "cax11"
  size = 1
  ssh_key = hcloud_ssh_key.default.id
}

module "worker-sm" {
  source = "./hetzner_nodegroup"
  image  = "ubuntu-24.04"
  location = "nbg1"
  name = "sm"
  role = "worker"
  server_type = "cax11"
  size = 1
  ssh_key = hcloud_ssh_key.default.id
}

module "worker-lg" {
  source = "./hetzner_nodegroup"
  image  = "ubuntu-24.04"
  location = "nbg1"
  name = "lg"
  role = "worker"
  server_type = "cax31"
  size = 1
  ssh_key = hcloud_ssh_key.default.id
}

module "cluster" {
  source = "./k0s_cluster"
  name   = "oxygen"
  nodes  = concat(
    module.controller.nodes,
    module.worker-lg.nodes,
    module.worker-sm.nodes
  )
  sshkey = ".ssh/key"
  extensions = {
    helm : {
      repositories : [
        {
          name : "fluxcd-community",
          url : "https://fluxcd-community.github.io/helm-charts"
        },
        {
          name : "hcloud",
          url : "https://charts.hetzner.cloud"
        },
      ],
      charts : [
        {
          order: 1
          name : "hetzner-ccm-secrets"
          chartname : "oci://ghcr.io/danielr1996/secret"
          version : "1.0.0"
          namespace: "kube-system"
          values: <<EOF
                      name: hcloud
                      values:
                        token: ${var.hcloud.token}
                    EOF
        },
        {
          order: 2
          name : "hetzner-ccm"
          chartname : "hcloud/hcloud-cloud-controller-manager"
          version : "1.20.0"
          namespace: "kube-system"
          values: ""
        },
        {
          order: 3
          name : "flux2"
          chartname : "fluxcd-community/flux2"
          version : "2.13.0"
          namespace: "flux-system"
          values: ""
        },
      ]
    }
  }
}


output "k0sctl" {
  value = module.cluster.k0sctl
}