/**
 * Copyright 2026 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "upcloud_kubernetes_cluster" "kubernetes" {
  network = var.network_id
  zone    = var.zone

  name                    = local.kubernetes.name
  plan                    = local.kubernetes.plan
  private_node_groups     = local.kubernetes.enablePrivateNodes
  control_plane_ip_filter = local.kubernetes.masterAuthorizedNetworks

  upgrade_strategy_type = local.kubernetes.updateStrategyType # "rolling-update"
  storage_encryption    = local.kubernetes.storageEncryption  # "data-at-rest"

  lifecycle {
    prevent_destroy = true
  }
}

resource "upcloud_kubernetes_node_group" "node_pool" {
  for_each = { for item in local.kubernetes.nodePools : item.name => item }

  cluster = upcloud_kubernetes_cluster.kubernetes.id

  name       = each.value.name
  node_count = each.value.minNodeCount
  plan       = each.value.machineType

  cloud_native_plan {
    storage_size = each.value.diskSizeGb
  }

  anti_affinity          = true
  utility_network_access = false

  ssh_keys = []

  lifecycle {
    prevent_destroy = true
  }
}

data "upcloud_kubernetes_cluster" "kubernetes" {
  id = upcloud_kubernetes_cluster.kubernetes.id
}

# Output kubeconfig to file
resource "local_file" "kubeconfig" {
  count    = var.store_kubeconfig ? 1 : 0
  content  = data.upcloud_kubernetes_cluster.kubernetes.kubeconfig
  filename = "${path.root}/kubeconfig.yaml"
}
