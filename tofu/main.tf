resource "tls_private_key" "sshkey" {
  algorithm = "ED25519"
}

output "sshkey" {
  value = tls_private_key.sshkey.private_key_openssh
  sensitive = true
}

resource "hcloud_ssh_key" "default" {
  name       = "default"
  public_key = tls_private_key.sshkey.public_key_openssh
}

resource "hcloud_server" "single" {
  name        = "single"
  server_type = "cax21"
  location    = "nbg1"
  image       = "ubuntu-24.04"
  ssh_keys    = [hcloud_ssh_key.default.id]
}

locals {
  hostkeys = [hcloud_server.single.ipv4_address]
}

resource "terraform_data" "updatehostkeys" {
  provisioner "local-exec" {
    command     = <<-EOF
      touch $HOME/.ssh/known_hosts
      %{ for ip in  local.hostkeys}
      ssh-keygen -R ${ip}
      ssh-keyscan -H ${ip} >> $HOME/.ssh/known_hosts
      %{ endfor }
      exit 0
    EOF
    interpreter = ["bash", "-c"]
  }
}


variable "cluster" {
  type = object({
    name = string
  })
}
output "k0sctl" {
  value = yamlencode({
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    metadata : {
      name = var.cluster.name
    }
    spec : {
      hosts : [
        {
          role         = "single"
          installFlags = ["--kubelet-extra-args=--node-ip=${hcloud_server.single.ipv4_address}"]
          openSSH : {
            address = hcloud_server.single.ipv4_address,
            user    = "root",
            port    = 22,
            keyPath = "default",
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
            extensions : local.extensions
          }
        }
      }
    }
  })
}