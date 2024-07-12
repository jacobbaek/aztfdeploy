# Create virtual machine
resource "azurerm_linux_virtual_machine" "cpnodes" {
  count                 = var.cpnode_count
  name                  = format("%s-cpnode%s", var.res_prefix, count.index)
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.cpnode_nic[count.index].id]
  size                  = var.cpnode_size

  os_disk {
    name                 = format("%s-cpnodedisk%s", var.res_prefix, count.index)
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.image_info.publisher
    offer     = var.image_info.offer
    sku       = var.image_info.sku
    version   = var.image_info.version
  }

  computer_name                   = format("%s-cpnode%s", var.res_prefix, count.index)
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa.primary_blob_endpoint
  }
}
