resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  number  = false
}

locals {
  project_name = "${var.app_name}-${random_string.random.result}"
}

# module "backend" {
#   source = "./modules"
#   rg_name = ""
#   rg_location = ""
#   acr_name = ""
#   acr_sku = ""
#   admin_enabled = false
#   storage_account_name = ""
#   account_tier = "Standard"
#   account_replication_type = "LRS"
#   storage_container_name = ""
#   container_access_type = "private"
# }



resource "azurerm_resource_group" "rg" {
  name     = "${local.project_name}-rg-backend"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "${random_string.random.result}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}
#https://www.youtube.com/watch?v=7ftpkd2DFJ0

# resource "azurerm_storage_account" "storage_account" {
#   name                     = random_string.random.result
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   tags = {
#     environment = "staging"
#   }
# }

# resource "azurerm_storage_container" "example" {
#   name                  = "terraform"
#   storage_account_name  = azurerm_storage_account.storage_account.name
#   container_access_type = "private"
# }
