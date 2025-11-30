# VM Module Outputs
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

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${module.vm.vm_public_ip}"
}

# Alerts Module Outputs (conditional)
output "alerts_enabled" {
  description = "Whether alerts are enabled"
  value       = var.enable_alerts
}

output "action_group_id" {
  description = "ID of the action group (if alerts enabled)"
  value       = var.enable_alerts ? module.vm_alerts[0].action_group_id : null
}

output "cpu_alert_id" {
  description = "ID of the CPU alert (if alerts enabled)"
  value       = var.enable_alerts ? module.vm_alerts[0].cpu_alert_id : null
}

output "memory_alert_id" {
  description = "ID of the memory alert (if alerts enabled)"
  value       = var.enable_alerts ? module.vm_alerts[0].memory_alert_id : null
}

