resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location #"West Europe"
}

# resource "azurerm_role_assignment" "role_assignment" {
#   scope                = azurerm_resource_group.rg.id
#   role_definition_name = "Storage Account Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name #"${random_string.random.result}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku #"Basic"
  admin_enabled       = var.acr_admin_enabled
}
#https://www.youtube.com/watch?v=7ftpkd2DFJ0

# resource "azurerm_storage_account" "storage_account" {
#   name                     = var.storage_account_name #random_string.random.result
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = var.account_tier             #"Standard"
#   account_replication_type = var.account_replication_type #"LRS"

#   # tags = {
#   #   environment = "staging"
#   # }
# }

# resource "azurerm_storage_container" "storage_container" {
#   name                  = var.storage_container_name
#   storage_account_name  = azurerm_storage_account.storage_account.name
#   container_access_type = var.container_access_type #"private"
# }

resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "Purge",
      "Recover",
      "Restore",
      "Update"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover"
    ]

    storage_permissions = ["Get", "List", "Update", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "secret_acr_name" {
  name         = "acr-name"
  value        = azurerm_container_registry.acr.name
  key_vault_id = azurerm_key_vault.keyvault.id
}

# resource "azurerm_key_vault_secret" "secret_storage_account_name" {
#   name         = "storage-account-name"
#   value        = azurerm_storage_account.storage_account.name
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

resource "azurerm_key_vault_secret" "secret_arc_admin_user" {
  count        = var.acr_admin_enabled ? 1 : 0
  name         = "arc-admin-user"
  value        = azurerm_container_registry.acr.admin_username
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "secret_acr_admin_password" {
  count        = var.acr_admin_enabled ? 1 : 0
  name         = "acr-admin-password"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.keyvault.id
}
