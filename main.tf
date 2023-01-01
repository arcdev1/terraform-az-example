# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.25.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "webapptfstatestor"
    container_name       = "webapp"
    key                  = "terraform.tfstate"
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "webapp_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "webapp_laws" {
  location            = azurerm_resource_group.webapp_rg.location
  name                = var.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  retention_in_days   = var.log_analytics_workspace_retention_in_days
  sku                 = var.log_analytics_workspace_sku
  tags                = var.tags
  depends_on          = [azurerm_resource_group.webapp_rg]
}

# Application Insights
resource "azurerm_application_insights" "webapp_apin" {
  application_type    = var.app_insights_application_type
  location            = azurerm_resource_group.webapp_rg.location
  name                = var.app_insights_name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  workspace_id        = azurerm_log_analytics_workspace.webapp_laws.id
  tags                = var.tags
  depends_on = [
    azurerm_resource_group.webapp_rg,
    azurerm_log_analytics_workspace.webapp_laws
  ]
}

output "instrumentation_key" {
  value     = azurerm_application_insights.webapp_apin.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.webapp_apin.app_id
}

# Application Service Plan 
resource "azurerm_service_plan" "webapp_asp" {
  location            = azurerm_resource_group.webapp_rg.location
  name                = var.app_service_plan_web_name
  os_type             = var.app_service_plan_web_os
  resource_group_name = azurerm_resource_group.webapp_rg.name
  sku_name            = var.app_service_plan_web_sku
  tags                = var.tags
  depends_on = [
    azurerm_resource_group.webapp_rg
  ]
}

# Application
resource "azurerm_linux_web_app" "webapp" {
  location            = azurerm_resource_group.webapp_rg.location
  name                = var.app_webapp_name
  resource_group_name = azurerm_resource_group.webapp_rg.name
  service_plan_id     = azurerm_service_plan.webapp_asp.id
  tags                = var.tags
  depends_on = [
    azurerm_resource_group.webapp_rg,
    azurerm_service_plan.webapp_asp
  ]
  site_config {
  }
}

# Key Vault
resource "azurerm_key_vault" "example" {
  name                       = "mykeyvault"
  location                   = azurerm_resource_group.webapp_rg.location
  resource_group_name        = azurerm_resource_group.webapp_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "Purge",
      "Recover"
    ]

    secret_permissions = [
      "Set",
    ]
  }
}

data "azurerm_key_vault" "example" {
  name                = "mykeyvault"
  resource_group_name = azurerm_resource_group.webapp_rg.name
}

data "azurerm_key_vault_secret" "test" {
  name         = "db_password"
  key_vault_id = data.azurerm_key_vault.example.id
}

#PostgreSQL
module "postgresql" {
  source = "Azure/postgresql/azurerm"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  server_name                  = "example-server"
  sku_name                     = "GP_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login          = "login"
  administrator_password       = data.azurerm_key_vault_secret.test.value
  server_version               = "9.5"
  ssl_enforcement_enabled      = true
  db_names                     = ["my_db1", "my_db2"]
  db_charset                   = "UTF8"
  db_collation                 = "English_United States.1252"

  firewall_rule_prefix = "firewall-"
  firewall_rules = [
    { name = "test1", start_ip = "10.0.0.5", end_ip = "10.0.0.8" },
    { start_ip = "127.0.0.0", end_ip = "127.0.1.0" },
  ]

  vnet_rule_name_prefix = "postgresql-vnet-rule-"
  vnet_rules = [
    { name = "subnet1", subnet_id = "<subnet_id>" }
  ]

  postgresql_configurations = {
    backslash_quote = "on",
  }

  tags = var.tags
  depends_on = [
    azurerm_resource_group.webapp_rg
  ]

}
