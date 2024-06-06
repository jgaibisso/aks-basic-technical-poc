
## --------------------------------------
##  KEYVAULT
## --------------------------------------

module "keyvault" {
  source = "../modules/key_vault"

  name                = "kv-${local.name_suffix}-526"
  location            = var.location
  rg_name             = azurerm_resource_group.rg_core.name
  kv_admins_ad_group  = "g-sec-global-keyvault-admins"
  kv_readers_ad_group = "g-sec-global-keyvault-readers"

  tags = var.tags
}

module "key_vault_private_dns_zone" {
  source              = "../modules/private_dns_zone"
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_core.name
  virtual_networks_to_link = {
    (module.aks_virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg_network.name
    }
  }
}


module "key_vault_private_endpoint" {
  source                         = "../modules/private_endpoint"
  name                           = "${title(module.keyvault.name)}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg_core.name
  subnet_id                      = module.aks_pe_subnet.id
  tags                           = var.tags
  private_connection_resource_id = module.keyvault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.key_vault_private_dns_zone.id]
}
