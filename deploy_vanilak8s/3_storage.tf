# Create storage account for boot diagnostics

resource "azurerm_storage_account" "sa" {
  name                     = format("%sstorage%s", var.res_prefix, random_string.random4str.result)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
