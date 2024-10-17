output "bastion_public_ip" {
    description = "Public IP address of Bastion host"
    value       = azurerm_public_ip.bastion_public_ip.ip_address
}

output "bastion_name" {
    description = "The name of the Bastion host"
    value       = azurerm_bastion_host.bastion.name
}