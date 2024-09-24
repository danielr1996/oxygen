variable "nodes" {
  type = list(object({
    role    = string
    address = string
    user    = string
    port    = number,
  }))
}

variable "name" {
  type = string
}

variable "sshkey" {}

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
            keyPath = var.sshkey,
          }
        }
        ],
#      k0s : {
#        config : {
#          spec : {
#            network: {
#              provider: "calico"
#              kubeProxy: {
#                mode: "ipvs"
#              }
#            }
#            api : {
##              externalAddress : hcloud_load_balancer.controller.ipv4,
##              sans: [hcloud_load_balancer.controller.ipv4]
#            },
#            extensions : {
#              helm : {
#                repositories : [
#                  {
#                    name : "fluxcd-community",
#                    url : "https://fluxcd-community.github.io/helm-charts"
#                  },
#                  {
#                    name : "hcloud",
#                    url : "https://charts.hetzner.cloud"
#                  },
#                ],
#                charts : [
#                  {
#                    order: 1
#                    name : "hetzner-ccm-secrets"
#                    chartname : "oci://ghcr.io/danielr1996/secret"
#                    version : "1.0.0"
#                    namespace: "kube-system"
#                    values: <<EOF
#                      name: hcloud
#                      values:
#                        token: tJGScVztGm2CMsmbULGGekeOPCH1tTEyaGGcDLsQ9F7fnuuWbmBW8NiYTASt1vPn
#                    EOF
#                  },
#                  {
#                    order: 2
#                    name : "hetzner-ccm"
#                    chartname : "hcloud/hcloud-cloud-controller-manager"
#                    version : "1.20.0"
#                    namespace: "kube-system"
#                    values: ""
#                  },
#                  {
#                    order: 3
#                    name : "flux2"
#                    chartname : "fluxcd-community/flux2"
#                    version : "2.13.0"
#                    namespace: "flux-system"
#                    values: ""
#                  },
#                ]
#              }
#            }
#          }
#        }
#      }
    }
  })
}

