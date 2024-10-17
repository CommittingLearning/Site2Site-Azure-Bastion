provider "azurerm" {
    features {}

    subscription_id = var.azure_subscription_id
    client_id       = var.azure_client_id
    tenant_id       = var.azure_tenant_id
}

terraform {
  backend "azurerm" {}
}