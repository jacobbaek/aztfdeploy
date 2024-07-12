resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-rg", var.res_prefix)
}
