# dev
resource "azurerm_kubernetes_cluster" "k8s-dev" {
  location            = azurerm_resource_group.rg-dev.location
  name                = format("%s-new-cluster", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg-dev.name
  dns_prefix          = format("%s-domain", var.res_prefix)
  node_resource_group = format("%s-noderg", var.res_prefix)
  tags                = {
    Environment = "Development"
  }

  kubernetes_version = var.aks_version

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.aks_node_size
    node_count = var.agent_count
    orchestrator_version = var.aks_version
    linux_os_config {
       transparent_huge_page_enabled = "madvise"
       transparent_huge_page_defrag = "defer+madvise"
       #swap_file_size_mb = "1500"
       sysctl_config {
         #netCoreSomaxconn = "163849"
         net_core_somaxconn = "163849"
         #netIpv4TcpTwReuse = "true"
         #netIpv4IpLocalPortRange = "32000 60000"
       }
    }
    vnet_subnet_id      = azurerm_subnet.cluster-dev.id
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin    = var.aks_network_plugin
    load_balancer_sku = "standard"
    outbound_type      = "loadBalancer"

  }
}

# stg
resource "azurerm_kubernetes_cluster" "k8s-stg" {
  location            = azurerm_resource_group.rg-stg.location
  name                = format("%s-stg-cluster", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg-stg.name
  dns_prefix          = format("%s-stg-domain", var.res_prefix)
  node_resource_group = format("%s-stg-noderg", var.res_prefix)
  tags                = {
    Environment = "staging"
  }

  kubernetes_version = var.aks_version

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.aks_node_size
    node_count = var.agent_count
    orchestrator_version = var.aks_version
    linux_os_config {
       transparent_huge_page_enabled = "madvise"
       transparent_huge_page_defrag = "defer+madvise"
       #swap_file_size_mb = "1500"
       sysctl_config {
         #netCoreSomaxconn = "163849"
         net_core_somaxconn = "163849"
         #netIpv4TcpTwReuse = "true"
         #netIpv4IpLocalPortRange = "32000 60000"
       }
    }
    vnet_subnet_id      = azurerm_subnet.cluster-stg.id
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin    = var.aks_network_plugin
    load_balancer_sku = "standard"
    outbound_type      = "loadBalancer"

  }
}
