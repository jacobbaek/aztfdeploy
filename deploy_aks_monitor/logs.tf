resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "${var.prefix}-dce"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # 모범사례: DCE는 교체 시 중복 생성-전환을 위해 CB4D를 두는 경우가 많음
  lifecycle {
    create_before_destroy = true
  }
}

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

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc_ci" {
  name                    = "${var.prefix}-dcrassoc-ci"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_ci.id
  description             = "Attach Container Insights DCR to AKS"
}
