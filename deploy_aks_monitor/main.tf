# -----------------------------
# 0) 공통: 리소스 그룹
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# -----------------------------
# 1) Log Analytics Workspace
#    - Container Insights 로그 수집 대상
# -----------------------------
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku                = "PerGB2018"
  retention_in_days  = 30
}

# -----------------------------
# 2) AKS 클러스터
#    - SystemAssigned MI
#    - OMS 에이전트 애드온 활성화 (AMA/ama-logs pod 배포)
# -----------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"

  default_node_pool {
    name                = "system"
    vm_size             = "Standard_DS2_v2"
    node_count          = 1
    orchestrator_version = var.kubernetes_version # (선택) 빈 값이면 최신 안정판
  }

  identity {
    type = "SystemAssigned"
  }

  # Container Insights 활성화 - ama-logs pod 배포
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    msi_auth_for_monitoring_enabled = true
  }
}

# -----------------------------
# 3) Data Collection Endpoint (DCE)
#    - AMA가 데이터를 보낼 엔드포인트
# -----------------------------
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "${var.prefix}-dce"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # 모범사례: DCE는 교체 시 중복 생성-전환을 위해 CB4D를 두는 경우가 많음
  lifecycle {
    create_before_destroy = true
  }
}


# 4) Data Collection Rule (Container Insights용) - 수정 버전
resource "azurerm_monitor_data_collection_rule" "dcr_ci" {
  name                        = "MSCI-${azurerm_resource_group.rg.location}-${azurerm_kubernetes_cluster.aks.name}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  # Container Insights는 Linux 기반 에이전트이므로 kind 지정(권장)
  kind = "Linux"

  # 목적지: Log Analytics
  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
    }
  }

  # 데이터 소스: ContainerInsights Extension(AMA)
  # 스트림을 명시적으로 선언 + V2 로그 활성화
  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      extension_name = "ContainerInsights"

      # CI에서 사용되는 대표 스트림(필요에 따라 조정 가능)
      streams = [
        # "Microsoft-ContainerLog",
        # "Microsoft-ContainerLogV2",
        "Microsoft-ContainerLogV2-HighScale",
        "Microsoft-KubeEvents",
        "Microsoft-KubePodInventory",
        "Microsoft-InsightsMetrics",
        "Microsoft-ContainerInventory",
        "Microsoft-ContainerNodeInventory",
        "Microsoft-KubeNodeInventory",
        "Microsoft-KubeServices",
        "Microsoft-KubePVInventory"
      ]

      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = var.ci_interval          # 예: "1m" 또는 "5m"
          namespaceFilteringMode = var.ci_namespace_mode     # "Off" | "Include" | "Exclude"
          namespaces             = var.ci_namespaces         # ["kube-system", ...]
          enableContainerLogV2   = true                      # V2 로그 테이블 활성화 (강력 권장)
        }
      })
    }

    # (선택) Syslog 수집을 함께 원하면 아래 활성화
    # syslog {
    #   name           = "node-syslog"
    #   facility_names = ["*"]
    #   log_levels     = ["*"]
    # }
  }

  # 데이터 플로우: 명시적 스트림 → LAW
  data_flow {
    streams = [
      #"Microsoft-ContainerLog",
      # "Microsoft-ContainerLogV2",
      "Microsoft-ContainerLogV2-HighScale",
      "Microsoft-KubeEvents",
      "Microsoft-KubePodInventory",
      "Microsoft-InsightsMetrics",
      "Microsoft-ContainerInventory",
      "Microsoft-ContainerNodeInventory",
      "Microsoft-KubeNodeInventory",
      "Microsoft-KubeServices",
      "Microsoft-KubePVInventory"
    ]
    destinations = ["ciworkspace"]
  }
}

# -----------------------------
# 5) DCR Association: DCR ↔ AKS 연결
#    - 이 연결이 되어야 클러스터에 AMA(컨테이너)가 배포·적용됩니다
# -----------------------------
resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc_ci" {
  name                    = "${var.prefix}-dcrassoc-ci"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_ci.id
  description             = "Attach Container Insights DCR to AKS"
}

# (선택) 제어판(control plane) 로그, Managed Prometheus도 함께 원하시면
# 별도 DCR/DCE/Association 구성을 병행합니다. AKS 모니터링 온보딩 시
# 여러 기능(프라메테우스/컨테이너 로그/제어판 로그)이 서로 다른 워크스페이스/규칙으로
# 분리될 수 있습니다.[1](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable)
