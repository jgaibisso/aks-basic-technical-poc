## --------------------------------------
##  VIRTUAL NETWORK
## --------------------------------------

module "aks_virtual_network" {
  source = "../modules/virtual_network"

  name                = "vnet-${local.name_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_network.name
  address_space       = var.aks_vnet_address_space

  tags = var.tags
}

## --------------------------------------
##  SUBNETS
## --------------------------------------

module "aks_default_node_pool_subnet" {
  source = "../modules/subnet"

  name                = "default-node-pool-snet"
  resource_group_name = azurerm_resource_group.rg_network.name
  vnet_name           = module.aks_virtual_network.name
  snet_address_range  = var.default_node_pool_subnet_address_prefix

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = false
}

module "aks_pod_subnet" {
  source = "../modules/subnet"

  name                = "pod-snet"
  resource_group_name = azurerm_resource_group.rg_network.name
  vnet_name           = module.aks_virtual_network.name
  snet_address_range  = var.pod_subnet_address_prefix

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = false
}

module "aks_pe_subnet" {
  source = "../modules/subnet"

  name                = "pe-snet"
  resource_group_name = azurerm_resource_group.rg_network.name
  vnet_name           = module.aks_virtual_network.name
  snet_address_range  = var.pod_subnet_address_prefix

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = false
}
