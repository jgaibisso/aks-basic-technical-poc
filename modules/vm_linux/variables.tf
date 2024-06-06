variable "name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
}

variable "location" {
  description = "Azure region for the virtual machine"
  type        = string
}

variable "rg_name" {
  description = "Resource group name where the virtual machine will be created"
  type        = string
}

variable "vm_size" {
  description = "Size of the Azure virtual machine"
  type        = string
}

variable "username" {
  description = "Username for the virtual machine"
  type        = string
}

variable "zone" {
  description = "Availability zone in which to deploy the virtual machine"
  type        = string
  default     = null
}

variable "os_storage_account_type" {
  description = "Type of storage account to use for the OS disk"
  type        = string
}

variable "os_disk_size_gb" {
  description = "Size in GB of the OS disk"
  type        = number
}

variable "subnet_id" {
  description = "The ID of the subnet where the network interface will be attached."
  type        = string
}

variable "private_ip_address_allocation" {
  description = "Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  type        = string
}

variable "private_ip_address" {
  description = "The static private IP address to assign to the network interface, if applicable."
  type        = string
}

variable "key_vault_id" {
  type        = string
  description = "Id of the keyvault to store SSH key"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
