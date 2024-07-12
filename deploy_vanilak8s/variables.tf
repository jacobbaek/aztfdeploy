variable "res_prefix" {
  default     = "vanilak8s"
  description = "this prefix will be used anywhere"
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

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa"
}

variable "vnet_addr" {
  default = {
    vnet_cidr = "10.200.0.0/16"
    cp_subnet_cidr = "10.200.0.0/22"
    node_subnet_cidr = "10.200.4.0/22"
  }
  description = "input cidr"
}

## VM settings
variable "image_info" {
  default = {
    # 'az vm image list -l koreacentral'
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  description = "input image properties"
}

variable "node_size" {
  default = "Standard_D2s_v5"
}

variable "cpnode_size" {
  default = "Standard_D2s_v5"
}

variable "deploy_size" {
  default = "Standard_D2s_v5"
}

variable "node_count" {
  default = 2
  description = "node count"
}

variable "cpnode_count" {
  default = 3
  description = "control plane node count"
}
