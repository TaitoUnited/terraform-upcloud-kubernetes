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

/* TODO: enable keepalive for socat? */
resource "helm_release" "postgres_proxy" {
  depends_on = [upcloud_kubernetes_cluster.kubernetes]

  for_each         = { for item in(local.helmEnabled ? local.postgresqlClusters : []) : item.name => item }
  name             = each.value.name
  namespace        = "db-proxy"
  create_namespace = true
  repository       = "https://isotoma.github.io/charts/"
  chart            = "socat-tunneller"
  version          = var.socat_tunneler_version
  wait             = false

  set = [
    {
      name  = "tunnel.host"
      value = each.value.privateAddress
    },
    {
      name  = "tunnel.port"
      value = 11550
    },
    {
      name  = "tunnel.localPort"
      value = 11550
    }
  ]
}

/* TODO: enable keepalive for socat? */
resource "helm_release" "mysql_proxy" {
  depends_on = [upcloud_kubernetes_cluster.kubernetes, helm_release.postgres_proxy]

  for_each   = { for item in(local.helmEnabled ? local.mysqlClusters : []) : item.name => item }
  name       = each.value.name
  namespace  = "db-proxy"
  repository = "https://isotoma.github.io/charts/"
  chart      = "socat-tunneller"
  version    = var.socat_tunneler_version
  wait       = false

  set = [
    {
      name  = "tunnel.host"
      value = each.value.privateAddress
    },
    {
      name  = "tunnel.port"
      value = 11550
    },
    {
      name  = "tunnel.localPort"
      value = 11550
    }
  ]
}
