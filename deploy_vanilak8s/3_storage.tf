# Create storage account for boot diagnostics
resource "azurerm_storage_account" "sa" {
  name                     = format("%sstorage", var.res_prefix)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
