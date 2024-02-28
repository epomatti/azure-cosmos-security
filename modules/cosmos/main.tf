resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "cosmos-${var.workload}-${random_integer.ri.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"


  local_authentication_disabled = true
  enable_automatic_failover     = false


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
    type               = "Continuous"
    retention_in_hours = 8
    storage_redundancy = "Local"
  }

}
