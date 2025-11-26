resource "azurerm_monitor_workspace" "amw" {
  name                = "${var.prefix}-amw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  # 필요 시 사설접속만 허용하려면 아래 주석 해제
  # public_network_access_enabled = false
  tags = {
    workload = "aks-monitoring"
  }
}

# ====== DCR 생성: Prometheus 메트릭을 AMW로 라우팅 ======
resource "azurerm_monitor_data_collection_rule" "dcr_prom" {
  name                = "dcr-prom-${var.prefix}-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  # DCR과 AMW는 같은 지역이어야 하는 점 유의
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  # 목적지: Managed Prometheus(AMW)
  destinations {
    monitor_account {
      name              = "MonitoringAccount1"
      monitor_account_id = azurerm_monitor_workspace.amw.id
    }
  }

  # 데이터 흐름: Prometheus 스트림 -> 목적지(AMW)
  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }

  # 데이터 소스: prometheus_forwarder (AKS의 ama-metrics가 이 소스로 전송)
  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
      # (필요 시 labelIncludeFilter, labelExcludeFilter 등 고급필터 설정 가능)
    }
  }

  tags = {
    workload = "aks-monitoring"
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcra_aks" {
  name                     = "dcra-prom-${var.prefix}-cluster"
  target_resource_id       = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id  = azurerm_monitor_data_collection_rule.dcr_prom.id
  description              = "Associate Prometheus DCR to AKS"
}
