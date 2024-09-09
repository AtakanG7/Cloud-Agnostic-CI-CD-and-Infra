variable "kubernetes_cluster_name" {
  description = "Name of the Kubernetes cluster"
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
