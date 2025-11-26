output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "dce_id" {
  value = azurerm_monitor_data_collection_endpoint.dce.id
}

output "dcr_ci_id" {
   value = azurerm_monitor_data_collection_rule.dcr_ci.id
}
