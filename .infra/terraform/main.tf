provider "azurerm" {
  features {}
}

module "kubernetes" {
  source = "./modules/azure"
  resource_group_name      = var.resource_group_name
  kubernetes_cluster_name  = var.kubernetes_cluster_name
  location                 = var.location
  node_count               = var.node_count
  vm_size                  = var.vm_size
}