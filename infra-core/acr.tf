
## --------------------------------------
##  ACR
## --------------------------------------

module "container_registry" {
  source                     = "../modules/container_registry"
  name                       = "acr${local.name_suffix}457"
  resource_group_name        = azurerm_resource_group.rg_core.name
  location                   = var.location
  sku                        = "Basic"
  admin_enabled              = false
  georeplication_locations   = []
  log_analytics_workspace_id = module.log_analytics_workspace.id
}


resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.id
  principal_id                     = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

module "acr_private_dns_zone" {
  source              = "../modules/private_dns_zone"
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg_core.name
  virtual_networks_to_link = {
    (module.aks_virtual_network.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg_network.name
    }
  }
}

module "acr_private_endpoint" {
  source                         = "../modules/private_endpoint"
  name                           = "${module.container_registry.name}PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg_core.name
  subnet_id                      = module.aks_pe_subnet.id
  tags                           = var.tags
  private_connection_resource_id = module.container_registry.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
}
