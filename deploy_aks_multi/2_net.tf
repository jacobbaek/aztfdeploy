# dev
resource "azurerm_virtual_network" "vnet-dev" {
  name        = format("%s-dev-vnet", var.res_prefix)
  address_space    = [var.aks_network.vnet_cidr]
  resource_group_name = azurerm_resource_group.rg-dev.name
  location      = azurerm_resource_group.rg-dev.location
}

resource "azurerm_subnet" "cluster-dev" {
  name         = "cluster-dev"
  virtual_network_name = azurerm_virtual_network.vnet-dev.name
  resource_group_name = azurerm_resource_group.rg-dev.name
  address_prefixes   = [var.aks_network.subnet_cidr]
}

# stg
resource "azurerm_virtual_network" "vnet-stg" {
  name        = format("%s-stg-vnet", var.res_prefix)
  address_space    = [var.aks_network.vnet_cidr]
  resource_group_name = azurerm_resource_group.rg-stg.name
  location      = azurerm_resource_group.rg-stg.location
}

resource "azurerm_subnet" "cluster-stg" {
  name         = "cluster-stg"
  virtual_network_name = azurerm_virtual_network.vnet-stg.name
  resource_group_name = azurerm_resource_group.rg-stg.name
  address_prefixes   = [var.aks_network.subnet_cidr]
}
