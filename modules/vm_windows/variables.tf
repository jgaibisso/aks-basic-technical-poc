variable "location" {
  type        = string
  description = "Region to create environment"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "name" {
  type        = string
  description = "Vm name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id"
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`"
  default     = "Dynamic"
}

variable "private_ip_address" {
  type        = string
  description = "The Static IP Address which should be used."
  default     = null
}

variable "zone" {
  type        = string
  description = "Specifies the Availability Zone in which this Windows Virtual Machine should be located."
  default     = null
}

variable "admin_username" {
  type        = string
  description = "Vm admin username"
}

variable "vm_size" {
  type        = string
  description = "Vm size"
}

variable "os_storage_account_type" {
  type        = string
  description = "Vm os disk storage account type"
}

variable "os_disk_size_gb" {
  type        = string
  description = "Vm os disk storage account size"
  default     = null
}

variable "key_vault_id" {
  type        = string
  description = "Keyvault id"
}

variable "publisher" {
  type        = string
  description = "Image publisher"
}

variable "offer" {
  type        = string
  description = "Image offer"
}

variable "sku" {
  type        = string
  description = "Image sku"
}

variable "data_disks" {
  type = list(object({
    type                 = string
    storage_account_type = string
    disk_size_gb         = number
    lun                  = number
    caching              = string
  }))

  # Validates that lun number is unique
  validation {
    condition     = length(var.data_disks) == length(distinct(var.data_disks[*].lun))
    error_message = "Each disk must have an unique lun."
  }

  description = "Aditional data disks"
  default     = []
}

variable "dc_domain" {
  type        = string
  description = "DC domain"
  default     = "well.local"
}

variable "dc_username" {
  type        = string
  description = "DC username"
  default     = "svc-domainjoin"
}

variable "dc_ou_path" {
  type        = string
  description = "Organizational unit (OU) path"
  default     = ""
}

## ------------------------------------
##  Azure Monitoring Variables
## ------------------------------------

variable "enable_azure_monitor_agent" {
  type        = bool
  description = "Install Azure Monitor Agent Extension"
  default     = false
}
