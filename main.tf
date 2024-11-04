# Create a dedicated public ip for Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
    name                = "bastion-public-ip-${var.environment}"
    location            = var.location
    resource_group_name = "${var.rg_name}_${var.environment}"
    allocation_method   = var.IPAllocation
    sku                 = var.IPsku
}

# Create a Bastion Host in the Bastion Subnet
resource "azurerm_bastion_host" "bastion" {
    name                = "bastion-${var.environment}"
    location            = var.location
    resource_group_name = "${var.rg_name}_${var.environment}"
    sku                 = var.Bastionsku

    ip_configuration {
        name                 = "bastionConfig"
        subnet_id            = data.azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
    }
}