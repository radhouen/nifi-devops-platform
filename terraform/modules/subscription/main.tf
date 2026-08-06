resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-${var.region_short}-rg"
  location = var.location

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
    region      = var.region_short
  }
}
