resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = format("%s-cluster", var.res_prefix)
  resource_group_name = azurerm_resource_group.rg.name
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
    vnet_subnet_id      = azurerm_subnet.cluster.id
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
  ## addons
  web_app_routing {
    dns_zone_id = ""
  }
  #### https://github.com/hashicorp/terraform-provider-azurerm/issues/24503
  # node_provisioning_mode = "auto"

  lifecycle {
    ignore_changes = [
      network_profile[0].nat_gateway_profile
    ]
  }
}
