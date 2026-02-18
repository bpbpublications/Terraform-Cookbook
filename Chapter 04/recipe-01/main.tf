module "vnet" {
  source              = "Azure/network/azurerm"
  version             = "3.5.0"
  resource_group_name = "ch4-r1-rg"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["default"]
}
