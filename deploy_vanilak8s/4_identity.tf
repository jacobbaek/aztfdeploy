resource "azurerm_user_assigned_identity" "uid" {
  name                = format("%s-id", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}