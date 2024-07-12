# Create a deploy virtual machine
resource "azurerm_linux_virtual_machine" "deploy" {
  name                  = format("%s-deploy", var.res_prefix)
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.deploy_nic.id]
  size                  = var.deploy_size

  os_disk {
    name                 = format("%s-deploydisk", var.res_prefix)
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.image_info.publisher
    offer     = var.image_info.offer
    sku       = var.image_info.sku
    version   = var.image_info.version
  }

  computer_name                   = format("%s-deploy", var.res_prefix)
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

locals {
  kubespray_hosts = <<-EOT
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases

  [kube_control_plane]
  node1

  [etcd]
  node1

  [kube_node]
  node1

  [k8s_cluster:children]
  kube_node
  kube_control_plane
  EOT
}

# resource "local_file" "inventory" {
#   filename = "kubespray_hosts.ini"
#   content  = local.kubespray_hosts
# }

resource "remote_file" "hosts_file" {
  conn {
    host     = azurerm_public_ip.deploy_public_ip.ip_address
    port     = 22
    user     = "azureuser"
    private_key = file(var.ssh_private_key)
  }

  path        = "/home/azureuser/hosts.ini"
  content     = local.kubespray_hosts
  permissions = "0644"
}

resource "null_resource" "provision_deploy" {
  connection {
    host     = azurerm_public_ip.deploy_public_ip.ip_address
    type     = "ssh"
    user     = "azureuser"
    private_key = "${file(var.ssh_private_key)}"
    timeout = "10s"
  }

  provisioner "file" {
    source      = "./scripts/deploy.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
}
