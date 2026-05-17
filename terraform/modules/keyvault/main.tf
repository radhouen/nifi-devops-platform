data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "${var.project}-${var.region_short}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]

    key_permissions = [
      "Get", "List", "Create", "Delete"
    ]
  }

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}

resource "azurerm_container_registry" "main" {
  name                = "${replace(var.project, "-", "")}${var.region_short}acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}
