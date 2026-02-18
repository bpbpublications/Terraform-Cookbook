# Map describing each storage account: key = logical identifier.
variable "storage_accounts" {
  description = "Map of storage account definitions"
  type = map(object({
    location = string  # Azure region, for example "UK South"
    tier     = string  # Account tier, "Standard" or "Premium"
  }))
}