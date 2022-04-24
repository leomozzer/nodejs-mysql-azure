resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location #"West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name #"${random_string.random.result}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku #"Basic"
  admin_enabled       = var.admin_enabled
}
#https://www.youtube.com/watch?v=7ftpkd2DFJ0

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name #random_string.random.result
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier             #"Standard"
  account_replication_type = var.account_replication_type #"LRS"

  # tags = {
  #   environment = "staging"
  # }
}

resource "azurerm_storage_container" "storage_container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type #"private"
}
