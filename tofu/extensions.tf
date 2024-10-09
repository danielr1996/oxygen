locals {
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
        {
          name : "tf-controller",
          url : "https://flux-iac.github.io/tofu-controller"
        },
      ],
      charts : [
        {
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
          name : "hetzner-ccm"
          chartname : "hcloud/hcloud-cloud-controller-manager"
          version : "1.20.0"
          namespace: "kube-system"
          values: ""
        },
        {
          name : "hetzner-csi"
          chartname : "hcloud/hcloud-csi"
          version : "2.9.0"
          namespace: "kube-system"
          values: <<EOF
                      node:
                        kubeletDir: /var/lib/k0s/kubelet
                    EOF
        },
        {
          name : "flux2"
          chartname : "fluxcd-community/flux2"
          version : "2.13.0"
          namespace: "flux-system"
          values: ""
        },
        {
          name : "tf-controller"
          chartname : "tf-controller/tf-controller"
          version : "0.15.1"
          namespace: "flux-system"
          values: ""
        },
      ]
    }
  }
}