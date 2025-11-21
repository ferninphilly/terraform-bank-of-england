output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ${local_file.private_key.filename} ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "vm_size_used" {
  description = "VM size that was actually used"
  value = var.vm_size != "" ? var.vm_size : (
    var.environment == "prod" ? "Standard_B2ms" : (
      var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
    )
  )
}

output "ansible_status" {
  description = "Whether Ansible provisioning was enabled"
  value       = var.enable_ansible ? "Enabled" : "Disabled"
}

