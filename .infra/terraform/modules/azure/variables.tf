variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the Kubernetes cluster."
  type        = number
}

variable "vm_size" {
  description = "The size of the VM."
  type        = string
}

variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}