resource "azurerm_cosmosdb_account" "db" {
  name                = "cosmos-${var.workload}-${var.random_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  local_authentication_disabled = true
  enable_automatic_failover     = false

  key_vault_key_id      = var.keyvault_key_id
  default_identity_type = join("=", ["UserAssignedIdentity", var.cosmos_identity_id])

  public_network_access_enabled         = var.public_network_access_enabled
  ip_range_filter                       = var.ip_range_filter
  network_acl_bypass_for_azure_services = true
  is_virtual_network_filter_enabled     = true

  virtual_network_rule {
    id                                   = var.compute_subnet_id
    ignore_missing_vnet_service_endpoint = false
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.cosmos_identity_id]
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "eastus"
    failover_priority = 0
    zone_redundant    = false
  }

  backup {
    type = "Continuous"
  }
}

resource "azurerm_cosmosdb_sql_database" "db001" {
  name                = "sqldb"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_cosmosdb_sql_container" "c001" {
  name                  = "example-container"
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.db.name
  database_name         = azurerm_cosmosdb_sql_database.db001.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "cosmos" {
  name                       = "logs"
  target_resource_id         = azurerm_cosmosdb_account.db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }
  enabled_log {
    category = "QueryRuntimeStatistics"
  }
  enabled_log {
    category = "PartitionKeyStatistics"
  }
  enabled_log {
    category = "PartitionKeyRUConsumption"
  }
  enabled_log {
    category = "ControlPlaneRequests"
  }

  metric {
    category = "Requests"
    enabled  = true
  }
}
