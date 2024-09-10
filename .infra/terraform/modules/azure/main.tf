provider "azurerm" {
  features {}

  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  tenant_id       = var.ARM_TENANT_ID
  subscription_id = var.ARM_SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.kubernetes_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.kubernetes_cluster_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

# Helm provider
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    templatefile("${path.module}/monitoring/prometheus-values.yaml", {
      grafana_password = random_password.grafana_admin_password.result
    })
  ]
}

#  AlertManager Config
resource "kubernetes_config_map" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = "monitoring"
  }

  data = {
    "alertmanager.yml"    = file("${path.module}/monitoring/alertmanager.yml")
    "prometheus-rules.yml" = file("${path.module}/monitoring/prometheus-rules.yml")
  }
}

# Helm Release for Database
resource "helm_release" "database" {
  name       = "database"
  chart      = "${path.module}/helm/database/database-1.0.0.tgz"
  namespace  = "production"
  version    = "1.0.0"

  values = [file("${path.module}/helm/database/values-production.yaml")]
}

# Helm Release for Web App
resource "helm_release" "web_app" {
  name       = "web-app"
  chart      = "${path.module}/helm/web-app/web-app-0.1.0.tgz" 
  version    = "1.0.0"
  namespace  = "production"

  values = [file("${path.module}/helm/web-app/values-production.yaml")]
}

# Helm Release for Worker
resource "helm_release" "worker" {
  name       = "worker"
  chart      = "${path.module}/helm/worker/worker-0.1.0.tgz"
  version    = "1.0.0"
  namespace  = "production"
  
  values = [file("${path.module}/helm/worker/values-production.yaml")]
}

# Generate random password for Grafana admin
resource "random_password" "grafana_admin_password" {
  length  = 16
  special = true
}

