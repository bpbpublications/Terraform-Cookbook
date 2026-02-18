variable "region" {
  type        = string
  description = "Azure Region"
}

variable "rg_name" {
  type        = string
  description = "Resource Group name"
}

variable "gateway_subnet_id" {
  type        = string
  description = "ID of the gateway subnet"
}

variable "web_vm_nics" {
  type        = list(string)
  description = "List of NIC IDs for Web VMs"
}
