variable "name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Region to create environment"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "kv_admins_ad_group" {
  type        = string
  description = "KeyVault admins group"
  default     = null
}

variable "kv_readers_ad_group" {
  type        = string
  description = "KeyVault readers group"
  default     = null
}

variable "secret_map" {
  type        = map(string)
  description = "A mapping of secrets to assign to the resource"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}