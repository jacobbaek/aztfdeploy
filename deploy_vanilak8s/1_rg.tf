# generate resourcegroup
resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-rg", var.res_prefix)
}

# generate random string 
resource "random_string" "random4str" {
  length  = 4
  upper = false
  special = false
}

# generate identity
resource "azurerm_user_assigned_identity" "uid" {
  name                = format("%s-id", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}