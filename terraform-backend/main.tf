resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  number  = false
}

locals {
  project_name  = "${var.app_name}-${random_string.random.result}"
  random_result = random_string.random.result
}

module "backend" {
  source                   = "./modules"
  rg_name                  = "${local.project_name}-rg-backend"
  rg_location              = "West Europe"
  acr_name                 = "${local.random_result}acr"
  acr_sku                  = "Basic"
  acr_admin_enabled        = false
  storage_account_name     = "${local.random_result}stac"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  storage_container_name   = "terraform"
  container_access_type    = "private"
  keyvault_name            = "${local.project_name}-kv"
}

output "rg_name" {
  value = "${local.project_name}-rg-backend"
}

output "acr_name" {
  value = "${local.random_result}acr"
}

output "storage_account_name" {
  value = "${local.random_result}stac"
}

output "storage_container_name" {
  value = "terraform"
}
