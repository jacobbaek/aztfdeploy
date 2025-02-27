output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s-dev.kube_config_raw
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.rg-dev.name
}

resource "local_file" "kubeconfig" {
  depends_on      = [azurerm_kubernetes_cluster.k8s-dev]
  filename        = "kubeconfig"
  content         = azurerm_kubernetes_cluster.k8s-dev.kube_config_raw
  file_permission = 600
}
