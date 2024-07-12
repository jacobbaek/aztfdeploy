resource "azurerm_log_analytics_workspace" "logws" {
  location            = var.log_workspace_location
  name                = format("%s-ws", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_workspace_sku
}

resource "azurerm_log_analytics_solution" "logsl" {
  location              = azurerm_log_analytics_workspace.logws.location
  resource_group_name   = azurerm_resource_group.rg.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.logws.name
  workspace_resource_id = azurerm_log_analytics_workspace.logws.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}
