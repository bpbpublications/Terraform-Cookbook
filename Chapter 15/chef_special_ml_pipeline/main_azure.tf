###############################################################
# Azure ML Stage: RG, Dependencies, Workspace, and Compute
###############################################################

# Random suffix for globally unique names across Azure (DNS/global namespaces)
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Caller/tenant context (used for Key Vault tenant_id, etc.)
data "azurerm_client_config" "current" {}

###############################################################
# Resource Group (root container for all Azure resources)
###############################################################
resource "azurerm_resource_group" "ml_rg" {
  name     = "rg-ml-${random_string.suffix.result}"
  location = var.az_location
}

###############################################################
# Application Insights (AML dependency)
# Collects metrics/telemetry for ML workspace jobs/endpoints
###############################################################
resource "azurerm_application_insights" "appi" {
  name                = "appi-ml-${random_string.suffix.result}"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  application_type    = "web"
}

###############################################################
# Key Vault (AML dependency)
# Stores secrets/keys; AML uses this for credentials and artifacts
###############################################################
resource "azurerm_key_vault" "kv" {
  name                     = "kvml${random_string.suffix.result}" # 3–24 chars, global uniqueness implied
  location                 = azurerm_resource_group.ml_rg.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false # consider true in prod to prevent hard-deletes

  # TIP: For production, enable soft delete & RBAC, and add access policies or RBAC roles.
}

###############################################################
# Storage Account (AML dependency)
# Backing store for datasets, runs, artifacts, logs
###############################################################
resource "azurerm_storage_account" "st" {
  name                            = "stml${random_string.suffix.result}" # 3–24 lower-case alphanumerics, globally unique
  location                        = azurerm_resource_group.ml_rg.location
  resource_group_name             = azurerm_resource_group.ml_rg.name
  account_tier                    = "Standard"
  account_replication_type        = "GRS" # geo-redundant; consider LRS/ZRS for cost/latency
  allow_nested_items_to_be_public = false # harden against public listing
}

# Private container for raw or preprocessed data
resource "azurerm_storage_container" "raw" {
  name                  = "raw-data"
  storage_account_name  = azurerm_storage_account.st.name
  container_access_type = "private"
}

###############################################################
# Azure Container Registry (recommended)
# Hosts training/inference images referred by the ML workspace
###############################################################
resource "azurerm_container_registry" "acr" {
  name                = "acrml${random_string.suffix.result}" # 5–50 lower-case alphanumerics, globally unique
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  sku                 = "Premium" # Premium enables features like geo-replication
  admin_enabled       = true      # convenient for demos; prefer RBAC/tokens in prod
}

###############################################################
# Azure Machine Learning Workspace (control plane)
# Wires together Insights, Key Vault, Storage, and ACR
###############################################################
resource "azurerm_machine_learning_workspace" "mlw" {
  name                = "mlw-${random_string.suffix.result}"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name

  application_insights_id = azurerm_application_insights.appi.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.st.id
  container_registry_id   = azurerm_container_registry.acr.id

  public_network_access_enabled = true # set false with private endpoints for locked-down networks

  identity {
    type = "SystemAssigned" # enables MSI for workspace-managed operations
  }
}

###############################################################
# Optional: Compute Cluster for preprocessing/training
# Auto-scales between 0..2 DSv2 CPU nodes for cost-efficient labs
###############################################################
resource "azurerm_machine_learning_compute_cluster" "cpu_cluster" {
  name                          = "cpucluster"
  location                      = azurerm_resource_group.ml_rg.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.mlw.id

  vm_size     = "Standard_DS11_v2" # choose GPU SKUs (e.g., Standard_NC6s_v3) for GPU workloads
  vm_priority = "Dedicated"        # or "LowPriority" for cheaper preemptible capacity

  scale_settings {
    min_node_count = 0 # scale to zero when idle
    max_node_count = 2 # cap for demos; raise for bigger jobs
    # ISO-8601 duration; PT5M = 5 minutes idle before scale-down
    scale_down_nodes_after_idle_duration = "PT5M"
  }

  # Optional hardening examples:
  # local_auth_enabled        = false
  # ssh_public_access_enabled = false
}
