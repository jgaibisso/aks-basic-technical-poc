environment = "dev"

tags = {
  "Environment" = "dev"
  "Owner"       = "Javier.Gaibisso"
  "Application" = "devops-agent"
  "ID"          = "00000001"
}

location = "eastus"

aks_vnet_address_space                  = ["10.0.0.0/16"]
default_node_pool_subnet_address_prefix = ["10.0.0.0/20"]
pod_subnet_address_prefix               = ["10.0.32.0/20"]
pe_subnet_address_prefix                = ["10.0.64.0/20"]
default_node_pool_vm_size               = "Standard_F8s_v2"