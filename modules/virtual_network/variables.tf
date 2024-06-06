variable "resource_group_name" {
  description = "EOT The name of the resource group in which to create the virtual network.The Resource Group must already exist."
  type        = string
}

variable "name" {
  description = "The name of the virtual network.Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80 && can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$", var.name))
    error_message = "Invalid name (check Azure Resource naming restrictions for more info)."
  }
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist.Changing this forces a new Resource Group to be created."
  type        = string
}

variable "address_space" {
  description = "The address space that is used the virtual network.You can supply more than one address space."
  type        = list(string)
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags which should be assigned to Resources."
  type        = map(string)
  default     = {}
}
