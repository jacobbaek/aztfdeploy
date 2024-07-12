resource "azurerm_virtual_network" "vnet" {
  name        = format("%s-vnet", var.res_prefix)
  address_space    = [var.aks_network.vnet_cidr]
  resource_group_name = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "cluster" {
  name         = "cluster"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  address_prefixes   = [var.aks_network.subnet_cidr]
}
