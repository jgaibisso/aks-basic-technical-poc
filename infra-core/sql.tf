# Azure SQL Server
resource "azurerm_mssql_server" "api_sql_server" {
  name                         = "api-sql-server"
  resource_group_name          = azurerm_resource_group.rg_core
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value

  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "api_database" {
  name           = "api-db"
  server_id      = azurerm_mssql_server.api_sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  sku_name       = "S0"
  zone_redundant = true

  tags = var.tags
}

module "sql_server_private_dns_zone" {
  source              = "../modules/private_dns_zone"
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg_core.name
  virtual_networks_to_link = {
    (module.aks_virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg_network.name
    }
  }
}

module "sql_server_private_endpoint" {
  source                         = "../modules/private_endpoint"
  name                           = "${title(azurerm_mssql_database.api_database.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg_core.name
  subnet_id                      = module.aks_pe_subnet.id
  tags                           = var.tags
  private_connection_resource_id = azurerm_mssql_database.api_database.id
  is_manual_connection           = false
  subresource_name               = "sqlServer"
  private_dns_zone_group_name    = "sqlPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.sql_server_private_dns_zone.id]
}