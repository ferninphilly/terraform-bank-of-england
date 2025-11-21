output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.vm.name
}

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine (if available)"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_location" {
  description = "Location where the VM was created"
  value       = azurerm_linux_virtual_machine.vm.location
}

output "vm_size" {
  description = "Size of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.size
}

