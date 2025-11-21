# Outputs from the module
output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.web_vm.vm_public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.web_vm.vm_private_ip
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.web_vm.vm_id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.web_vm.vm_name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = module.web_vm.ssh_command
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.web_vm.vnet_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.web_vm.subnet_id
}

output "vm_size_used" {
  description = "VM size that was actually used"
  value       = module.web_vm.vm_size_used
}

output "ansible_status" {
  description = "Whether Ansible provisioning was enabled"
  value       = module.web_vm.ansible_status
}

# Alert Module Outputs
output "alerts_enabled" {
  description = "Whether VM alerts are enabled"
  value       = module.web_vm_alerts.alerts_enabled
}

output "alert_count" {
  description = "Number of alerts configured for the VM"
  value       = module.web_vm_alerts.alert_count
}

output "action_group_id" {
  description = "ID of the action group for alerts (if email configured)"
  value       = module.web_vm_alerts.action_group_id
}

