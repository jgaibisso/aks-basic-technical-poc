variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Vnet containing the subnets"
}

variable "name" {
  type        = string
  description = "Snet address range"
  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80 && can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$", var.name))
    error_message = "Invalid name (check Azure Resource naming restrictions for more info)."
  }
}

variable "snet_address_range" {
  type        = list(string)
  description = "Snet address range"
}

variable "service_endpoints" {
  type        = set(string)
  description = "The list of Service endpoints to associate with the subnet"
  default     = []
}

variable "service_delegation_name" {
  type        = string
  description = "The name of service to delegate to"
  default     = null
}

variable "service_delegation_actions" {
  type        = list(string)
  description = "A list of Actions which should be delegated"
  default     = []
}

variable "private_endpoint_network_policies_enabled" {
  type    = bool
  default = true
}

variable "private_link_service_network_policies_enabled" {
  type    = bool
  default = false
}