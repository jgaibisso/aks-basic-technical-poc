# Configure the Microsoft Azure Backend block
terraform {
  required_version = "1.8.2"
  backend "azurerm" {

  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.48.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }

    /*     cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.3"
    } */

    /*     template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
 */
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  skip_provider_registration = true
}

provider "azapi" {
}

provider "tls" {
}