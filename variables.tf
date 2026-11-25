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

variable "email" {
  type        = string
  default     = ""
  description = "DevOps email"
}

variable "network_id" {
  type        = string
  default     = ""
  description = "Kubernetes network"
}

variable "zone" {
  type        = string
  default     = ""
  description = "UpCloud zone"
}

variable "store_kubeconfig" {
  type        = bool
  default     = false
  description = "Storage kubeconfig on local disk"
}

/* TODO
variable "create_registry" {
  type        = bool
  default     = "true"
  description = "Creates a container registry."
}

variable "grant_registry_access" {
  type        = bool
  default     = "false"
  description = "Grants registry access. If you have problems with this, set it to true only after Kubernetes cluster already exists."
}
*/

variable "kubernetes" {
  type = object({
    name                     = string
    plan                     = string
    enablePrivateNodes       = bool
    updateStrategyType       = optional(string, "manual")
    storageEncryption        = optional(string, "data-at-rest")
    masterAuthorizedNetworks = optional(list(string), [])

    nodePools = list(object({
      name        = string
      machineType = string
      /*
      acceleratorType = string
      acceleratorCount = number
      */
      diskSizeGb   = number
      minNodeCount = number
      /* maxNodeCount = number */
    }))

    certManager = optional(object({
      enabled           = optional(bool, false)
      gatewayApiEnabled = optional(bool, false)
    }))
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "permissions" {
  type = object({
    clusterRoles = list(object({
      name     = string
      subjects = list(string)
    }))
    namespaces = list(object({
      name = string
      clusterRoles = list(object({
        name     = string
        subjects = list(string)
      }))
    }))
  })
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm infrastructure apps

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
}

variable "generate_ingress_dhparam" {
  type        = bool
  default     = false
  description = "Generate Diffie-Hellman key for ingress"
}

variable "use_kubernetes_as_db_proxy" {
  type    = bool
  default = false
}

variable "postgresql_clusters" {
  type = list(object({
    name           = string
    privateAddress = optional(string)
  }))
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

variable "mysql_clusters" {
  type = list(object({
    name           = string
    privateAddress = optional(string)
  }))
  default     = []
  description = "Resources as JSON (see README.md). You can read values from a YAML file with yamldecode()."
}

# Helm app versions

variable "kubernetes_admin_version" {
  type    = string
  default = "1.18.0"
}

variable "socat_tunneler_version" {
  type    = string
  default = "0.2.0"
}

variable "cert_manager_version" {
  type    = string
  default = "1.21.3"
}
