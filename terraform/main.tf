provider "azurerm" {
  features = {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "wizrg" {
  name     = "wiz-rg"
  location = "eastus"
}
