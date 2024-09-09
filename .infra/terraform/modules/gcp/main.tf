resource "google_container_cluster" "example" {
  name     = var.kubernetes_cluster_name
  location = var.location

  initial_node_count = var.node_count
  node_config {
    machine_type = var.vm_size
  }

  # Define other GKE parameters as needed
}
