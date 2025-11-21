# CPU Usage Alert
resource "azurerm_monitor_metric_alert" "cpu_high" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-cpu-high-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when CPU usage exceeds ${var.cpu_threshold_percent}%"
  severity            = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
  enabled             = true

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.cpu_metric_name
    aggregation      = var.cpu_aggregation
    operator         = var.cpu_operator
    threshold        = var.cpu_threshold_percent

    dimension {
      name     = var.cpu_dimension_name
      operator = var.cpu_dimension_operator
      values   = [var.vm_name]
    }
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = var.cpu_window_size
  frequency   = var.cpu_frequency

  tags = var.tags
}

# Available Memory Alert (Low Memory)
resource "azurerm_monitor_metric_alert" "memory_low" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-memory-low-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when available memory is below ${100 - var.memory_threshold_percent}%"
  severity            = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
  enabled             = true

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.memory_metric_name
    aggregation      = var.memory_aggregation
    operator         = var.memory_operator
    threshold        = var.memory_threshold_bytes
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = var.memory_window_size
  frequency   = var.memory_frequency

  tags = var.tags
}

# Disk Read Operations Alert (High Disk Activity)
resource "azurerm_monitor_metric_alert" "disk_read_high" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-disk-read-high-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when disk read operations are unusually high"
  severity            = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
  enabled             = true

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.disk_read_metric_name
    aggregation      = var.disk_read_aggregation
    operator         = var.disk_read_operator
    threshold        = var.disk_read_threshold
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = var.disk_read_window_size
  frequency   = var.disk_read_frequency

  tags = var.tags
}

# Disk Write Operations Alert (High Disk Activity)
resource "azurerm_monitor_metric_alert" "disk_write_high" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-disk-write-high-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when disk write operations are unusually high"
  severity            = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
  enabled             = true

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.disk_write_metric_name
    aggregation      = var.disk_write_aggregation
    operator         = var.disk_write_operator
    threshold        = var.disk_write_threshold
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = var.disk_write_window_size
  frequency   = var.disk_write_frequency

  tags = var.tags
}

# Network In Alert (High Network Traffic)
resource "azurerm_monitor_metric_alert" "network_in_high" {
  count = var.enable_alerts ? 1 : 0

  name                = "${var.name_prefix}-network-in-high-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when network inbound traffic is unusually high"
  severity            = var.environment == "prod" ? var.alert_severity_prod : var.alert_severity_dev
  enabled             = true

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.network_in_metric_name
    aggregation      = var.network_in_aggregation
    operator         = var.network_in_operator
    threshold        = var.network_in_threshold
  }

  action {
    action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
  }

  window_size = var.network_in_window_size
  frequency   = var.network_in_frequency

  tags = var.tags
}

