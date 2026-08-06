terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "cgxnifitfstate"
    container_name       = "tfstate"
    key                  = "cgx-nifi-poc.tfstate"
  }
}
