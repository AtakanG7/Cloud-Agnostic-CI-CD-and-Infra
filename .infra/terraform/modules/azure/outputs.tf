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

# Output the kubeconfig
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}