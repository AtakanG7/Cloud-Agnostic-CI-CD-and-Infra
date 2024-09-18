# AWS provider configuration
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create an EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.kubernetes_cluster_name
  cluster_version = "1.21"
  subnets         = var.subnet_ids

  node_groups = {
    eks_nodes = {
      desired_capacity = var.node_count
      max_capacity     = var.node_count
      min_capacity     = var.node_count

      instance_type = var.instance_type
    }
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
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
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
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

# Data sources for AWS EKS
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}