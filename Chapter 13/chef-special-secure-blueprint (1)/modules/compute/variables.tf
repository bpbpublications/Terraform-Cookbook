variable "location"            { type = string }
variable "resource_prefix"     { type = string }
variable "default_tags"        { type = map(string) }

variable "rg_name"             { type = string }
variable "subnet_id"           { type = string }
variable "nsg_id"              { type = string }

variable "admin_username"      { type = string }
variable "ssh_public_key_path" { type = string }

# Secret URI to fetch inside the VM
variable "secret_uri" {
  type        = string
  description = "Key Vault secret URI for runtime retrieval"
  sensitive   = true
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name (for logging and checks)"
}
