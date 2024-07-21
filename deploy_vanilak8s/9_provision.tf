# provision script at the deploy VM

locals {
  kubespray_hosts = <<-EOT
  cpnode1 ansible_connection=${azurerm_network_interface.cpnode_nic[0].private_ip_address} local_release_dir={{ansible_env.HOME}}/releases
  cpnode2 ansible_connection=${azurerm_network_interface.cpnode_nic[1].private_ip_address} local_release_dir={{ansible_env.HOME}}/releases
  cpnode3 ansible_connection=${azurerm_network_interface.cpnode_nic[2].private_ip_address} local_release_dir={{ansible_env.HOME}}/releases
  node1 ansible_connection=${azurerm_network_interface.node_nic[0].private_ip_address} local_release_dir={{ansible_env.HOME}}/releases
  node2 ansible_connection=${azurerm_network_interface.node_nic[1].private_ip_address} local_release_dir={{ansible_env.HOME}}/releases

  [kube_control_plane]
  cpnode1
  cpnode2
  cpnode3

  [etcd]
  cpnode1
  cpnode2
  cpnode3

  [kube_node]
  node1
  node2

  [k8s_cluster:children]
  kube_node
  kube_control_plane
  EOT
}

resource "null_resource" "provision_deploy" {
  connection {
    host     = azurerm_public_ip.deploy_public_ip.ip_address
    type     = "ssh"
    user     = "azureuser"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    destination = "/home/azureuser/.ssh/id_rsa"
    content     = file(var.ssh_private_key)
  }

  provisioner "file" {
    destination = "/home/azureuser/hosts.ini"
    content     = local.kubespray_hosts
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

  depends_on = [azurerm_public_ip.deploy_public_ip]
}