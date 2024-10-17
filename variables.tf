variable "azure_subscription_id" {
    description = "The Subscription ID for the Azure account"
    type        = string
}

variable "azure_client_id" {
    description = "The Client ID (App ID) for the Azure Service Principal"
    type        = string 
}

variable "azure_tenant_id" {
    description = "The Tenant ID for the Azure account"
    type        = string
}

variable "rg_name" {
    description = "Name of the Resource Group"
    default     = "Site2Site_rg"
}

variable "location" {
    description = "Region of Deployment"
    default     = "West US"
}

variable "environment" {
    description = "The environment (e.g., development, production) to append to the VNet name"
    type        = string
}

variable "IPAllocation" {
    description = "Allocation method for the public IP"
    type        = string
    default     = "Static"
}

variable "IPsku" {
    description = "sku for the public IP"
    type        = string
    default     = "Standard"
}

variable "Bastionsku" {
    description = "sku value for Bastion deployment"
    type        = string
    default     = "Basic"
}