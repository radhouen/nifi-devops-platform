terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_subscription" "current" {}

output "subscription_id" {
  value = data.azurerm_subscription.current.id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
