data "terraform_remote_state" "vnet" {
    backend = "azurerm"
    config = {
        storage_account_name = "tsblobstore11${var.environment}"
        container_name       = "terraform-state"
        key                  = "Site2Site_VNet_${var.environment}.tfstate"
        resource_group_name  = "Site2Site_rg_${var.environment}"
        use_oidc             = true
        client_id            = var.azure_client_id
        tenant_id            = var.azure_tenant_id
        subscription_id      = var.azure_subscription_id
    }
}

data "azurerm_virtual_network" "vnet" {
    name                = data.terraform_remote_state.vnet.outputs.vnet_name
    resource_group_name = "${var.rg_name}_${var.environment}"
}

data "azurerm_subnet" "bastion_subnet" {
    name                 = data.terraform_remote_state.vnet.outputs.subnetbastion_name
    resource_group_name  = "${var.rg_name}_${var.environment}"
    virtual_network_name = data.terraform_remote_state.vnet.outputs.vnet_name
}