# oxygen
oxygen is a set of IaC ressources to bootstrap a kubernetes cluster in any cloud, baremetal, and hybrid.

> oxygen is not a turnkey solution, but a set of templates that you can fork and use as a starting point. This is aimed 
> mostly at developers, so I assume at least some familiarity with the required tools and the willingness to modify this 
> template according to your specific needs.
> I've chosen hetzner as the default provider since they offer a good price to performance ratio, while still offering
> good integration with tooling. If you choose hetzner you just need to set your credentials and configure the nodes. 
> If you want to use another cloud provider you can still get started pretty quickly, just swap the hetzner specific node
> configuration for your own.

# Requirements

- credentials for your cloud provider (`cp vars.auto.tfvars.example vars.auto.tfvars` and fill in your credentials )

The following software

- opentofu
- taskfile.dev
- k0sctl
- kubectl (optional but highly recommended, to interact with your cluster from the cli)
- flux (optional, for directly interacting with flux crds)
- openlens (optional, to interact with your cluster from a gui)

# Usage

>Configure the nodegroups in main.tf (size, os, type)

To see a list of all available commands
```
task --list
```

Create a cluster from scratch
```
task apply
```

Destroy the cluster
```
task destroy
```