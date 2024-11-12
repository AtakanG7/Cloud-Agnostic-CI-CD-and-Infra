module "kubernetes" {
  source = "./modules/azure"
  resource_group_name      = var.resource_group_name
  kubernetes_cluster_name  = var.kubernetes_cluster_name
  location                 = var.location
  node_count               = var.node_count
  vm_size                  = var.vm_size
  ARM_CLIENT_ID            = var.ARM_CLIENT_ID
  ARM_CLIENT_SECRET        = var.ARM_CLIENT_SECRET
  ARM_TENANT_ID            = var.ARM_TENANT_ID
  ARM_SUBSCRIPTION_ID      = var.ARM_SUBSCRIPTION_ID
}
