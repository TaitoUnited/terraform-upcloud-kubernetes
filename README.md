# UpCloud Kubernetes

Example usage:

```
provider "upcloud" {
}

# Kubernetes

module "kubernetes" {
  source              = "TaitoUnited/kubernetes/upcloud"
  version             = "0.0.1"

  # Misc settings
  email                      = "support@mydomain.com"
  zone                       = "FI-HEL2"
  network_id                 = module.network.network.id
  store_kubeconfig           = true

  # Permissions
  permissions                = yamldecode(
    file("${path.root}/../infra.yaml")
  )["permissions"]

  # Kubernetes
  kubernetes                 = yamldecode(
    file("${path.root}/../infra.yaml")
  )["kubernetes"]

  # Registry
  /* TODO
  create_registry            = true
  grant_registry_access      = false  # Should be false on the first run, then true
  */

  # Helm infrastructure apps
  helm_enabled               = false  # Should be false on the first run, then true
  generate_ingress_dhparam   = false
  use_kubernetes_as_db_proxy = true
  postgresql_clusters        = [{
    name: "my-postgresql-1"
    privateIp: "123.123.123.123"
  }]
  mysql_clusters        = [{
    name: "my-mysql-1"
    privateIp: "123.123.123.124"
  }]
}
```

Example YAML:

```
# Permissions
permissions:

  # Cluster-wide permissions
  clusterRoles:
    - name: taito-iam-admin
      subjects:
        - group:admins@mydomain.com
    - name: taito-status-viewer
      subjects:
        - group:staff@mydomain.com

  # Namespace specific permissions
  namespaces:
    - name: common
      clusterRoles:
        - name: taito-secret-viewer
          subjects:
            - group:developers@mydomain.com
            - user:cicd-tester@${taito_zone}.iam.gserviceaccount.com
    - name: db-proxy
      clusterRoles:
        - name: taito-pod-portforwarder
          subjects:
            - group:developers@mydomain.com
            - user:cicd-tester@${taito_zone}.iam.gserviceaccount.com
    - name: my-namespace
      clusterRoles:
        - name: taito-developer
          subjects:
            - user:john.doe@mydomain.com
            - user:jane.doe@mydomain.com
    - name: another-namespace
      clusterRoles:
        - name: taito-developer
          subjects:
            - user:john.doe@mydomain.com
            - user:jane.doe@mydomain.com

# For Kubernetes setting descriptions, see
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/private-cluster
kubernetes:
  name: zone1-common-kube1
  plan: prod-md
  enablePrivateNodes: true
  updateStrategyType: "rolling-update"
  storageEncryption: "data-at-rest"
  masterAuthorizedNetworks:
    - 0.0.0.0/0

  # Node pools
  nodePools:
    - name: pool-1
      machineType: PREMIUM-2xCPU-4GB
      diskSizeGb: 100
      minNodeCount: 1

  certManager:
    enabled: true
    gatewayApiEnabled: true

  # TIP: You can install more infrastructure apps on your Kubernetes with:
  # https://github.com/TaitoUnited/infra-apps-template
```

YAML attributes:

- See variables.tf for all the supported YAML attributes.
- See [kubernetes-engine](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/) for attribute descriptions.
- See [Cluster Roles](https://github.com/TaitoUnited/taito-charts/blob/master/kubernetes-admin/templates/clusterrole.yaml) of kubernetes-admin Helm Chart for all predefined role definitions (e.g. taito-developer, taito-status-viewer, taito-secret-viewer).

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Compute](https://registry.terraform.io/modules/TaitoUnited/compute/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
