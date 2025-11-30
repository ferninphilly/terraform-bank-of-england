# Action Group for Email Notifications
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts && var.alert_email != "" ? 1 : 0

  name                = "${var.name_prefix}-action-group"
  resource_group_name = var.resource_group_name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "email-receiver"
    email_address = var.alert_email
  }

  tags = var.tags
}

# CPU Usage Alert
resource "azurerm_monitor_metric_alert" "cpu_high" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-cpu-high-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when CPU usage exceeds ${var.cpu_threshold_percent}%"
  severity            = 2
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_percent
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = "PT5M"  # 5 minutes
  frequency   = "PT1M"  # Evaluate every minute

  tags = var.tags
}

# Memory Alert (Low Available Memory)
# Note: Azure provides "Available Memory Bytes" metric
# We'll alert when available memory is low (high usage)
resource "azurerm_monitor_metric_alert" "memory_low" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-memory-low-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when available memory is low (memory usage exceeds ${var.memory_threshold_percent}%)"
  severity            = 2
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    # Approximate calculation: For B1s (1GB RAM), alert if less than (100 - threshold)% available
    # This is a simplified calculation - adjust based on VM size
    threshold        = 157286400  # ~150MB for B1s (15% of 1GB)
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = "PT5M"  # 5 minutes
  frequency   = "PT1M"  # Evaluate every minute

  tags = var.tags
}

