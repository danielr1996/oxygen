locals {
  hetzner_extensions = {
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