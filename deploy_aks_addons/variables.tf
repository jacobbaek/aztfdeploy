variable "agent_count" {
  default = 2
}

# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_workspace_location" {
  default = "koreacentral"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_workspace_sku" {
  default = "PerGB2018"
}

variable "rg_location" {
  default     = "koreacentral"
  description = "Location of the resource group."
}

variable "res_prefix" {
  default     = "akstfaddon"
  description = "this prefix will be used anywhere"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "aks_network_plugin" {
  #default = "kubenet"
  default = "azure"
  description = "can choice the azure cni or kubenet"
}

variable "aks_version" {
  default = "1.29.2"
  description = "have to input right version, x.xx.x "
}

variable "aks_node_size" {
  default = "Standard_D2s_v5"
}

## secret information
#### To use identity is better than service principal.

variable "aks_sp_appId" {
  default = ""
}

variable "aks_sp_secret" {
  default = ""
}

