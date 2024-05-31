resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = format("%s-rg", var.res_prefix)
}

resource "azurerm_log_analytics_workspace" "logws" {
  location            = var.log_workspace_location
  name                = format("%s-ws", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.log_workspace_sku
}

resource "azurerm_log_analytics_solution" "logsl" {
  location              = azurerm_log_analytics_workspace.logws.location
  resource_group_name   = azurerm_resource_group.rg.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.logws.name
  workspace_resource_id = azurerm_log_analytics_workspace.logws.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
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
    vm_size    = "Standard_D2_v2"
    node_count = var.agent_count
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
  ## addons
  web_app_routing {
    dns_zone_id = ""
  }
  #### https://github.com/hashicorp/terraform-provider-azurerm/issues/24503
  # node_provisioning_mode = "auto"
}
