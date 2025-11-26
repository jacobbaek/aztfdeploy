variable "prefix" {
  description = "prefix"
  type        = string
  default     = "akstfmon"
}

variable "location" {
  description = "region"
  type        = string
  default     = "koreacentral"
}

variable "kubernetes_version" {
  description = "(optional) aks version, use stable version if you don't write "
  type        = string
  default     = null
}

variable "aks_network_plugin" {
  default = "azure"
  description = "can choice the azure cni or kubenet"
}

variable "node_count" {
  description = "how many nodes will deploy"
  type        = number
  default     = 1
}

variable "node_size" {
  description = "node sku name"
  type        = string
  default     = "Standard_D4ads_v5"
}

variable "ci_interval" {
  description = "collect period(e.g., 1m, 5m)"
  type        = string
  default     = "5m"
}

variable "ci_namespace_mode" {
  description = "namespace filtering mode : Off | Include | Exclude"
  type        = string
  default     = "Off"
}

variable "ci_namespaces" {
  description = "it's namespace list when mode is Include/Exclude"
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "public key when you access node"
  default     = "~/.ssh/id_rsa.pub"
}
