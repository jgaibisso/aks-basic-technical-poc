## --------------------------------------
##  LOCAL VARIABLES
## --------------------------------------

locals {
  name_suffix            = "${var.environment}-${var.location}-${var.application_name}"
  name_sufffix_short     = "${var.environment}${var.location}${var.application_name}"
  storage_account_prefix = "boot"
  route_table_name       = "DefaultRouteTable"
  route_name             = "RouteToAzureFirewall"
}

data "azurerm_client_config" "current" {
}

## --------------------------------------
##  RESOURCE GROUP
## --------------------------------------

resource "azurerm_resource_group" "rg_aks" {
  name     = "rg-aks-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg_network" {
  name     = "rg-vnet-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg_core" {
  name     = "rg-core-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}

## --------------------------------------
##  LOG ANALYTICS WORKSPACE
## --------------------------------------

module "log_analytics_workspace" {
  source              = "../modules/log_analytics"
  name                = "law-${local.name_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_core.name
  solution_plan_map   = var.solution_plan_map
}

## --------------------------------------
##  CREATE & STORE SSH KEY
## --------------------------------------

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key"
  value        = tls_private_key.ssh_key.public_key_openssh
  key_vault_id = module.keyvault.id
}

data "azurerm_key_vault_secret" "ssh_public_key_aks" {
  key_vault_id = module.keyvault.id
  name         = "ssh-public-key"
}

resource "random_password" "sql_password" {
  length = 15
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = random_password.sql_password.result
  key_vault_id = module.keyvault.id
}

data "azurerm_key_vault_secret" "sql_password" {
  key_vault_id = module.keyvault.id
  name         = "sql-password"
}



## --------------------------------------
##  AKS
## --------------------------------------

module "aks_cluster" {
  source = "../modules/aks"

  resource_group_name = azurerm_resource_group.rg_aks.name
  location            = var.location
  sku_tier            = "Free"
  name                = "aks-${local.name_suffix}"

  dns_prefix_private_cluster = "aks${local.name_suffix}"

  kubernetes_version      = "1.21.1"
  private_cluster_enabled = true
  azure_rbac_enabled      = false
  admin_username          = "BMIAdmin"


  default_node_pool_name                = "default"
  default_node_pool_vm_size             = "Standard_F8s_v2"
  default_node_pool_max_pods            = 50
  default_node_pool_enable_auto_scaling = true


  vnet_subnet_id             = module.aks_default_node_pool_subnet.id
  pod_subnet_id              = module.aks_pod_subnet.id
  outbound_type              = "loadBalancer"
  tenant_id                  = data.azurerm_client_config.current.tenant_id

  ssh_public_key             = data.azurerm_key_vault_secret.ssh_public_key_aks.value

  tags = var.tags
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                            = azurerm_resource_group.rg_network.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}
