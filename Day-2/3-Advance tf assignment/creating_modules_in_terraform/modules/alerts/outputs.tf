output "action_group_id" {
  description = "ID of the action group for alerts"
  value       = var.enable_alerts && var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
}

output "action_group_name" {
  description = "Name of the action group"
  value       = var.enable_alerts && var.alert_email != "" ? azurerm_monitor_action_group.main[0].name : null
}

output "cpu_alert_id" {
  description = "ID of the CPU usage alert"
  value       = var.enable_alerts ? azurerm_monitor_metric_alert.cpu_high[0].id : null
}

output "memory_alert_id" {
  description = "ID of the memory alert"
  value       = var.enable_alerts ? azurerm_monitor_metric_alert.memory_low[0].id : null
}

output "alerts_enabled" {
  description = "Whether alerts are enabled"
  value       = var.enable_alerts
}

output "alert_count" {
  description = "Number of alerts configured"
  value       = var.enable_alerts ? 7 : 0
}

