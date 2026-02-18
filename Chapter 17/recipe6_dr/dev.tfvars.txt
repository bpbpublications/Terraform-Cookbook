# Regions
primary_location = "eastus2"
dr_location      = "centralus" # pick a permitted region for SQL in your subscription

# Resource groups
primary_rg_name = "rg-ch17-managed-db"
dr_rg_name      = "rg-ch17-dr"

# Existing networking (from Recipe 1 and Recipe 4)
data_subnet_id          = "/subscriptions/1c29d694-6fa7-425d-9c70-75cd707c6cea/resourceGroups/rg-ch17-core-network/providers/Microsoft.Network/virtualNetworks/vnet-ch17/subnets/data-subnet"
sql_private_dns_zone_id = "/subscriptions/1c29d694-6fa7-425d-9c70-75cd707c6cea/resourceGroups/rg-ch17-managed-db/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"

# Primary SQL objects (from Recipe 4 outputs)
primary_sql_server_name = "sqlsvrch17cap0016u7n"
primary_database_name   = "appdb"

# Key Vault (from Recipe 2)
key_vault_id      = "/subscriptions/1c29d694-6fa7-425d-9c70-75cd707c6cea/resourceGroups/rg-ch17-secrets-identity/providers/Microsoft.KeyVault/vaults/kvch17capstone001"
key_vault_name    = "kvch17capstone001"
key_vault_rg_name = "rg-ch17-secrets-identity"


# Failover group
failover_group_name       = "fog-ch17-app"
rw_mode                   = "Automatic"
rw_grace_minutes          = 60
readonly_failover_enabled = true
