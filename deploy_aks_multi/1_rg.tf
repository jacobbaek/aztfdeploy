resource "azurerm_resource_group" "rg-dev" {
  location = var.rg_location
  name     = format("%s-dev-rg", var.res_prefix)
}

resource "azurerm_resource_group" "rg-stg" {
  location = var.rg_location
  name     = format("%s-stg-rg", var.res_prefix)
}
