# Action Group for Alert Notifications
# Only create if alerts are enabled and email is provided
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts && var.alert_email != "" ? 1 : 0

  name                = "${var.name_prefix}-alerts-ag"
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  email_receiver {
    name          = var.email_receiver_name
    email_address = var.alert_email
  }

  tags = var.tags
}

