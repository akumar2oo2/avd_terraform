# Azure Resource Manager Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # Authentication via env vars (ARM_CLIENT_ID, ARM_CLIENT_SECRET, etc.)
  # or via az login session
}

# Azure AD Provider
provider "azuread" {}

# AzAPI Provider (for AVD session host cleanup)
provider "azapi" {}

# Random Provider (used by scaling module for role assignment names)
provider "random" {}

# Null Provider (used for NetworkWatcherRG cleanup local-exec)
provider "null" {}