# dev
resource "azurerm_kubernetes_cluster_node_pool" "userpool-dev" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s-dev.id
  vm_size               = var.aks_node_size
  node_count            = var.agent_count
  orchestrator_version  = var.aks_version

  tags = {
    Environment = "Dev"
  }
}

# stg
resource "azurerm_kubernetes_cluster_node_pool" "userpool-stg" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s-stg.id
  vm_size               = var.aks_node_size
  node_count            = var.agent_count
  orchestrator_version  = var.aks_version

  tags = {
    Environment = "Staging"
  }
}
