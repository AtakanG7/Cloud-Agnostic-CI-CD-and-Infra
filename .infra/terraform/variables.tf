variable "resource_group_name" {
  description = "Name of the resource group or equivalent"
  type        = string
}
variable "kubernetes_cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}
variable "location" {
  description = "Location of the resources"
  type        = string
}
variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
}
variable "vm_size" {
  description = "Size of the VM"
  type        = string
}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}