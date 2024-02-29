terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.93.0"
    }
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

locals {
  workload = "centralbank"
  suffix   = random_integer.ri.result
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_user_assigned_identity" "cosmos" {
  name                = "cosmos"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

module "keyvault" {
  source              = "./modules/keyvault"
  workload            = local.workload
  group               = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  random_suffix       = local.suffix
  cosmos_principal_id = azurerm_user_assigned_identity.cosmos.principal_id
}

module "cosmos" {
  source                        = "./modules/cosmos"
  workload                      = local.workload
  resource_group_name           = azurerm_resource_group.default.name
  location                      = azurerm_resource_group.default.location
  log_analytics_workspace_id    = azurerm_log_analytics_workspace.default.id
  keyvault_key_id               = module.keyvault.keyvault_key_versionless_id
  random_suffix                 = local.suffix
  cosmos_identity_id            = azurerm_user_assigned_identity.cosmos.id
  public_network_access_enabled = var.public_network_access_enabled
}

# module "vm_linux" {
#   count               = var.create_vm_linux == true ? 1 : 0
#   source              = "./modules/vm/linux"
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.default.name
#   location            = azurerm_resource_group.default.location
#   subnet_id           = module.vnet.subnet_id
#   size                = var.vm_linux_size
#   image_sku           = var.vm_linux_image_sku
# }
