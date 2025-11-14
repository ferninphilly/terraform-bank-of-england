# outputs.tf

output "public_ip_address" {
  description = "The public IP address to connect to the Linux VM via SSH."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "ssh_command" {
  description = "The command required to SSH into the provisioned server."
  value = "ssh -i azure-vm-key ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}