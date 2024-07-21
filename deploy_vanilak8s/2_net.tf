# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-vnet", var.res_prefix)
  address_space       = [var.vnet_addr.vnet_cidr]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Create subnet
resource "azurerm_subnet" "cpnode_subnet" {
  name         = "controlplanesubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.vnet_addr.cp_subnet_cidr]
}

resource "azurerm_subnet" "node_subnet" {
  name         = "nodesubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.vnet_addr.node_subnet_cidr]
}

# Create public IPs
resource "azurerm_public_ip" "cpnode_public_ip" {
  count               = var.cpnode_count
  name                = format("%s-cpnode-pip%s", var.res_prefix, count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "node_public_ip" {
  count               = var.node_count
  name                = format("%s-node-pip%s", var.res_prefix, count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "deploy_public_ip" {
  name                = format("%s-deploy-pip", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = format("%s-lb-pip", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "node_nic" {
  count               = var.node_count
  name                = format("%s-node-nic-%s", var.res_prefix, count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = format("%s-node-nicconf-%s", var.res_prefix, count.index)
    subnet_id                     = azurerm_subnet.node_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node_public_ip[count.index].id
  }
}

resource "azurerm_network_interface" "cpnode_nic" {
  count               = var.cpnode_count
  name                = format("%s-cpnode-nic-%s", var.res_prefix, count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = format("%s-cpnode-nicconf-%s", var.res_prefix, count.index)
    subnet_id                     = azurerm_subnet.cpnode_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cpnode_public_ip[count.index].id
  }
}

resource "azurerm_network_interface" "deploy_nic" {
  name                = format("%s-deploy-nic", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = format("%s-deploy-nicconf", var.res_prefix)
    subnet_id                     = azurerm_subnet.cpnode_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.deploy_public_ip.id
  }
}
