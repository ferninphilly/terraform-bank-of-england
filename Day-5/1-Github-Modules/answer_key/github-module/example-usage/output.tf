# Output VM information
output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.vm.vm_name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.vm.vm_public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.vm.vm_private_ip
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vm.vnet_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.vm.subnet_id
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${module.vm.vm_public_ip}"
}

