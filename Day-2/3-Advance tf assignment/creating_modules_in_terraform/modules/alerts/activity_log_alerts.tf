# VM Deallocation Alert
resource "azurerm_monitor_activity_log_alert" "vm_deallocated" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-vm-deallocated-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = var.vm_deallocated_description

  criteria {
    resource_id    = var.vm_id
    operation_name = var.vm_deallocate_operation_name
    category       = var.activity_log_category_administrative
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  tags = var.tags
}

# VM Power Off Alert
resource "azurerm_monitor_activity_log_alert" "vm_poweroff" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-vm-poweroff-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM is powered off"

  criteria {
    resource_id    = var.vm_id
    operation_name = var.vm_poweroff_operation_name
    category       = var.activity_log_category_administrative
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  tags = var.tags
}

# VM Health Status Alert
resource "azurerm_monitor_activity_log_alert" "vm_health" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-vm-health-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = var.vm_health_description

  criteria {
    resource_id = var.vm_id
    category    = var.activity_log_category_service_health
    level       = var.vm_health_level
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  tags = var.tags
}

