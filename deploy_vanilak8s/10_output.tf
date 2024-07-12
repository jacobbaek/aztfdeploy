output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "deploy_publicip_address" {
  # value = azurerm_linux_virtual_machine.deploy.deploy_public_ip_address
  value = azurerm_public_ip.deploy_public_ip.ip_address
  # value = azurerm_network_interface.deploy_nic
}

output "node_publicip_address" {
  # value = azurerm_linux_virtual_machine.nodes[*].node_public_ip_address
  value = azurerm_public_ip.node_public_ip[*].ip_address
}

output "cpnode_publicip_address" {
  # value = azurerm_linux_virtual_machine.cpnodes[*].cpnode_public_ip_address
  value = azurerm_public_ip.cpnode_public_ip[*].ip_address
}
