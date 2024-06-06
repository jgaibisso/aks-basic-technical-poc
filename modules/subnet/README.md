# Terraform module to create Azure Resource Group

This module creates Azure Resource Group.
It also has the option to create a lock on the Resource Group scope.
This module also validates the name according to the Azure Resource naming
restrictions.

**NOTE: To use the lock level option the service principal must have the "Owner"
or "User Access Administrator" roles.**

## Usage

```hcl

module "rg" {
  source = "../../"

  name     = "rgdemo"
  location = "North Europe"

  tags = {
    ManagedBy   = "Terraform"
    Environment = "sandbox"
  }
}

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| azurerm | >= 2.41.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.41.0 |

## Modules

No Modules.