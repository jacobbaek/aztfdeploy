resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "systemnp"
    vm_size    = var.node_size
    node_count = var.node_count
    orchestrator_version = var.kubernetes_version 
    linux_os_config {
       transparent_huge_page_defrag = "defer+madvise"
       sysctl_config {
         net_core_somaxconn = "163849"
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
    outbound_type      = "loadBalancer"

  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }

  # Prometheus 메트릭 수집 활성화 (ama-metrics pod 배포)
  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }
}
