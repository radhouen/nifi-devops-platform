output "resource_group_name" {
  value = module.subscription.resource_group_name
}

output "location" {
  value = module.subscription.location
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "aks_subnet_id" {
  value = module.networking.aks_subnet_id
}

output "appgw_subnet_id" {
  value = module.networking.appgw_subnet_id
}

output "key_vault_name" {
  value = module.security.key_vault_name
}

output "key_vault_uri" {
  value = module.security.key_vault_uri
}

output "acr_login_server" {
  value = module.security.acr_login_server
}
