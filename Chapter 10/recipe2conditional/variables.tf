variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "UK South"
}

variable "vm_size" {
  description = "Size of the backup virtual machine"
  type        = string
  default     = "Standard_B1ms"      # Low‑cost test size
}

variable "enable_backup" {
  description = "Flag to control creation of the backup VM"
  type        = bool
  default     = false                # Disabled by default
}