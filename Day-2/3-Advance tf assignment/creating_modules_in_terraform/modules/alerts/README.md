# VM Alerts Module

This module creates Azure Monitor alerts to monitor virtual machine health and performance.

## What This Module Creates

- **Action Group**: Email notification group for alerts
- **CPU Alert**: Monitors high CPU usage
- **Memory Alert**: Monitors low available memory
- **Disk Read Alert**: Monitors high disk read operations
- **Disk Write Alert**: Monitors high disk write operations
- **Network Alert**: Monitors high network inbound traffic
- **VM Deallocation Alert**: Alerts when VM is stopped/deallocated
- **VM Health Alert**: Alerts on VM health status changes

## Usage

```hcl
module "vm_alerts" {
  source = "./modules/alerts"
  
  vm_id              = module.web_vm.vm_id
  vm_name            = module.web_vm.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location           = "eastus"
  name_prefix        = "web"
  alert_email        = "admin@example.com"
}
```

## Required Variables

- `vm_id` - ID of the VM to monitor
- `vm_name` - Name of the VM
- `resource_group_name` - Resource group name
- `location` - Azure region
- `name_prefix` - Prefix for alert names

## Optional Variables

- `enable_alerts` - Enable/disable alerts (default: true)
- `alert_email` - Email for notifications (default: "")
- `cpu_threshold_percent` - CPU threshold (default: 80)
- `memory_threshold_percent` - Memory threshold (default: 85)
- `disk_threshold_percent` - Disk threshold (default: 90)
- `environment` - Environment (affects alert severity)

## Outputs

- `action_group_id` - Action group ID
- `cpu_alert_id` - CPU alert ID
- `memory_alert_id` - Memory alert ID
- `alerts_enabled` - Whether alerts are enabled
- `alert_count` - Number of alerts configured

## Alert Types

1. **Metric Alerts**: Monitor performance metrics (CPU, memory, disk, network)
2. **Activity Log Alerts**: Monitor VM state changes and health events

## Customization

Adjust thresholds based on your needs:
- Lower thresholds = more sensitive (more alerts)
- Higher thresholds = less sensitive (fewer alerts)
- Production environments typically use lower thresholds

