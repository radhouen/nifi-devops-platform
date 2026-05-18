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

module "subscription" {
  source       = "./modules/subscription"
  location     = var.location
  region_short = var.region_short
  project      = var.project
  environment  = var.environment
}

module "networking" {
  source              = "./modules/networking"
  project             = var.project
  environment         = var.environment
  region_short        = var.region_short
  location            = module.subscription.location
  resource_group_name = module.subscription.resource_group_name
  tags                = module.subscription.tags
  vnet_cidr           = var.vnet_cidr
  aks_subnet_cidr     = var.aks_subnet_cidr
  appgw_subnet_cidr   = var.appgw_subnet_cidr
}

module "security" {
  source              = "./modules/keyvault"
  project             = var.project
  environment         = var.environment
  region_short        = var.region_short
  location            = module.subscription.location
  resource_group_name = module.subscription.resource_group_name
  tags                = module.subscription.tags
}

module "aks" {
  source              = "./modules/aks"
  project             = var.project
  environment         = var.environment
  region_short        = var.region_short
  location            = module.subscription.location
  resource_group_name = module.subscription.resource_group_name
  tags                = module.subscription.tags
  aks_subnet_id       = module.networking.aks_subnet_id
  k8s_version         = var.k8s_version
  system_node_vm_size = var.system_node_vm_size
  nifi_node_vm_size   = var.nifi_node_vm_size
}
