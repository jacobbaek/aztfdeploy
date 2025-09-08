resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-rg", var.res_prefix)
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = format("%s-cluster", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = format("%s-domain", var.res_prefix)
  tags                = {
    Environment = "Development"
  }

  kubernetes_version = var.aks_version

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_E4_v3"
    node_count = var.agent_count
    linux_os_config {
       transparent_huge_page_enabled = "madvise"
       transparent_huge_page_defrag = "defer+madvise"
       sysctl_config {
         #netCoreSomaxconn = "163849"
         net_core_somaxconn = "163849"
         #netIpv4TcpTwReuse = "true"
         #netIpv4IpLocalPortRange = "32000 60000"
       }
    }
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
  }
}

resource "azurerm_kubernetes_cluster_extension" "container_storage" {
  name           = "microsoft-azurecontainerstorage"
  cluster_id     = azurerm_kubernetes_cluster.k8s.id
  extension_type = "microsoft.azurecontainerstorage"
  configuration_settings = {
    "enable-azure-container-storage" : "ephemeralDisk",
    "storage-pool-option" : "Temp",
    "azure-container-storage-nodepools" : "storagepool",
    "performanceTier" : "Standard"
  }
}
