provider "azurerm" {
  features {}

  client_id       = env.ARM_CLIENT_ID
  client_secret   = env.ARM_CLIENT_SECRET
  tenant_id       = env.ARM_TENANT_ID
  subscription_id = env.ARM_SUBSCRIPTION_ID
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

# Output the kubeconfig
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
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
  repository = file("${path.module}/helm/database/Chart.yaml")  
  chart      = "database"
  namespace  = "production"
  version    = "1.0.0"

  values = [file("${path.module}/helm/database/values-production.yaml")]
}

# Helm Release for Web App
resource "helm_release" "web_app" {
  name       = "web-app"
  repository = "${path.module}/helm/web-app/Chart.yaml"  
  chart      = "web-app"
  version    = "1.0.0"

  values = [file("${path.module}/helm/web-app/values-production.yaml")]
}

# Helm Release for Worker
resource "helm_release" "worker" {
  name       = "worker"
  repository = "${path.module}/helm/worker/Chart.yaml"
  chart      = "worker"
  version    = "1.0.0"

  values = [file("${path.module}/helm/worker/values-production.yaml")]
}

# Output Grafana admin password
output "grafana_admin_password" {
  value     = random_password.grafana_admin_password.result
  sensitive = true
}

# Output access instructions
output "access_instructions" {
  value = <<EOT
  To access Grafana:
  1. Run: kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
  2. Open a browser and go to: http://localhost:3000
  3. Log in with:
    Username: admin
    Password: ${random_password.grafana_admin_password.result}

  To verify Prometheus data source in Grafana:
  1. After logging in, go to Configuration > Data Sources
  2. You should see a Prometheus data source already configured

  To access Prometheus directly:
  1. Run: kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
  2. Open a browser and go to: http://localhost:9090

  To access AlertManager:
  1. Run: kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n monitoring
  2. Open a browser and go to: http://localhost:9093
  EOT
}

# Generate random password for Grafana admin
resource "random_password" "grafana_admin_password" {
  length  = 16
  special = true
}

# Output Prometheus endpoint
output "prometheus_endpoint" {
  value = "http://prometheus-server.monitoring.svc.cluster.local"
}

# Output AlertManager endpoint
output "alertmanager_endpoint" {
  value = "http://alertmanager.monitoring.svc.cluster.local"
}

# Output Grafana endpoint
output "grafana_endpoint" {
  value = "http://grafana.monitoring.svc.cluster.local"
}