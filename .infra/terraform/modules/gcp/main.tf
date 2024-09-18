# GCP provider configuration
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.gcp_credentials
}

# Create a GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.kubernetes_cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Create namespaces
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

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Prometheus installation
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

# AlertManager configuration
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

# Helm releases for applications
resource "helm_release" "database" {
  name       = "database"
  chart      = "${path.module}/helm/database/database-1.0.0.tgz"
  namespace  = "production"
  version    = "1.0.0"

  values = [file("${path.module}/helm/database/values-production.yaml")]
}

resource "helm_release" "web_app" {
  name       = "web-app"
  chart      = "${path.module}/helm/web-app/web-app-0.1.0.tgz"
  version    = "1.0.0"
  namespace  = "production"

  values = [file("${path.module}/helm/web-app/values-production.yaml")]
}

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

# Data source for GCP client configuration
data "google_client_config" "default" {}