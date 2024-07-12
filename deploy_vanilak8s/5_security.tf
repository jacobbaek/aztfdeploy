# Create Network Security Group and rule
resource "azurerm_network_security_group" "deploy_nsg" {
  name                = format("%s-deploy-nsg", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "cpnode_nsg" {
  name                = format("%s-cpnode-nsg", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_network_interface.deploy_nic.private_ip_address
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "node_nsg" {
  name                = format("%s-node-nsg", var.res_prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_network_interface.deploy_nic.private_ip_address
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "deploy_nic_nsg" {
  network_interface_id      = azurerm_network_interface.deploy_nic.id
  network_security_group_id = azurerm_network_security_group.deploy_nsg.id
}

resource "azurerm_network_interface_security_group_association" "node_nic_nsg" {
  count                     = var.node_count
  network_interface_id      = azurerm_network_interface.node_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.node_nsg.id
}

resource "azurerm_network_interface_security_group_association" "cpnode_nic_nsg" {
  count                     = var.cpnode_count
  network_interface_id      = azurerm_network_interface.cpnode_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.cpnode_nsg.id
}
