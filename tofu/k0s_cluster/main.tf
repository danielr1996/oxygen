variable "nodes" {
  type = list(object({
    role    = string
    address = string
    user    = string
    port    = number
    sshkey = string
  }))
}

variable "name" {
  type = string
}

variable "extensions" {}

output "k0sctl" {
  value = yamlencode({
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    metadata : {
      name = var.name
    }
    spec : {
      hosts : [
          for node in var.nodes :{
          role         = node.role
          installFlags = ["--kubelet-extra-args=--node-ip=${node.address}"]
          openSSH : {
            address = node.address,
            user    = node.user,
            port    = node.port,
            keyPath = node.sshkey,
          }
        }
        ],
      k0s : {
        config : {
          spec : {
            network: {
              provider: "calico"
              kubeProxy: {
                mode: "ipvs"
              }
            }
            api : {
#              externalAddress : hcloud_load_balancer.controller.ipv4,
#              sans: [hcloud_load_balancer.controller.ipv4]
            },
            extensions : var.extensions
          }
        }
      }
    }
  })
}

