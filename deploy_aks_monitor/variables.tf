variable "prefix" {
  description = "리소스 접두사 (고유 식별용)"
  type        = string
}

variable "location" {
  description = "리전"
  type        = string
  default     = "koreacentral"
}

variable "kubernetes_version" {
  description = "(선택) AKS 버전, 미지정 시 최신 안정판"
  type        = string
  default     = null
}

# Container Insights (AMA) 수집 파라미터
variable "ci_interval" {
  description = "수집 주기(e.g., 1m, 5m)"
  type        = string
  default     = "5m"
}

variable "ci_namespace_mode" {
  description = "네임스페이스 필터링 모드: Off | Include | Exclude"
  type        = string
  default     = "Off"
}

variable "ci_namespaces" {
  description = "Include/Exclude 모드일 때 적용할 네임스페이스 목록"
  type        = list(string)
  default     = []
}

