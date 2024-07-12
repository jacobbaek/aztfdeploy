resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.aks_node_size
  node_count            = var.agent_count
  orchestrator_version  = "1.28.9"

  tags = {
    Environment = "Production"
  }
}
