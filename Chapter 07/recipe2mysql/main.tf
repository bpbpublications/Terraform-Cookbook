resource "azurerm_resource_group" "rg" {
  name     = "ch7-r2-rg"
  location = var.region
}

resource "azurerm_virtual_network" "mysql_vnet" {
  name                = "mysql-vnet"
  address_space       = ["10.20.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.mysql_vnet.name
  address_prefixes     = ["10.20.1.0/24"]

  delegation {
    name = "fsdelegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet_link" {
  name                  = "mysqlDnsLink"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = azurerm_virtual_network.mysql_vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "ch7-mysql-flexible-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.region
  administrator_login    = "mysqladmin"
  administrator_password = var.mysql_password
  sku_name               = "GP_Standard_D2ds_v4"
  version                = "8.0.21"
  zone                   = "1"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_dns.id
  storage {
    size_gb = 50
  }
}