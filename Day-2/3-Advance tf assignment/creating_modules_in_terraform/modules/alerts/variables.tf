variable "vm_id" {
  type        = string
  description = "The ID of the virtual machine to monitor"
}

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for alert resource names"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "enable_alerts" {
  type        = bool
  description = "Whether to enable monitoring alerts"
  default     = true
}

variable "alert_email" {
  type        = string
  description = "Email address to receive alerts"
  default     = ""
}

variable "cpu_threshold_percent" {
  type        = number
  description = "CPU usage threshold percentage for alerts"
  default     = 80
}

variable "memory_threshold_percent" {
  type        = number
  description = "Memory usage threshold percentage for alerts"
  default     = 85
}

variable "disk_threshold_percent" {
  type        = number
  description = "Disk usage threshold percentage for alerts (not currently used in alerts, reserved for future use)"
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

# Alert Threshold Variables
variable "disk_read_threshold" {
  type        = number
  description = "Disk read operations per second threshold"
  default     = 1000
}

variable "disk_write_threshold" {
  type        = number
  description = "Disk write operations per second threshold"
  default     = 1000
}

variable "network_in_threshold" {
  type        = number
  description = "Network inbound traffic threshold in bytes (default: 10GB)"
  default     = 10737418240
}

# Action Group Configuration
variable "action_group_short_name" {
  type        = string
  description = "Short name for action group"
  default     = "vm-alerts"
}

variable "email_receiver_name" {
  type        = string
  description = "Name for email receiver"
  default     = "email-receiver"
}

# Alert Severity Configuration
variable "alert_severity_prod" {
  type        = number
  description = "Alert severity for production environment"
  default     = 2
}

variable "alert_severity_dev" {
  type        = number
  description = "Alert severity for dev/staging environment"
  default     = 3
}

# Metric Namespace
variable "metric_namespace" {
  type        = string
  description = "Metric namespace for VM metrics"
  default     = "Microsoft.Compute/virtualMachines"
}

# CPU Alert Configuration
variable "cpu_metric_name" {
  type        = string
  description = "CPU metric name"
  default     = "Percentage CPU"
}

variable "cpu_aggregation" {
  type        = string
  description = "CPU metric aggregation type"
  default     = "Average"
}

variable "cpu_operator" {
  type        = string
  description = "CPU alert operator"
  default     = "GreaterThan"
}

variable "cpu_dimension_name" {
  type        = string
  description = "CPU alert dimension name"
  default     = "VMName"
}

variable "cpu_dimension_operator" {
  type        = string
  description = "CPU alert dimension operator"
  default     = "Include"
}

variable "cpu_window_size" {
  type        = string
  description = "CPU alert evaluation window size"
  default     = "PT5M"
}

variable "cpu_frequency" {
  type        = string
  description = "CPU alert evaluation frequency"
  default     = "PT1M"
}

# Memory Alert Configuration
variable "memory_metric_name" {
  type        = string
  description = "Memory metric name"
  default     = "Available Memory Bytes"
}

variable "memory_aggregation" {
  type        = string
  description = "Memory metric aggregation type"
  default     = "Average"
}

variable "memory_operator" {
  type        = string
  description = "Memory alert operator"
  default     = "LessThan"
}

variable "memory_threshold_bytes" {
  type        = number
  description = "Memory threshold in bytes (calculated based on memory_threshold_percent)"
  default     = 157286400  # ~150MB for B1s with 15% free
}

variable "memory_window_size" {
  type        = string
  description = "Memory alert evaluation window size"
  default     = "PT5M"
}

variable "memory_frequency" {
  type        = string
  description = "Memory alert evaluation frequency"
  default     = "PT1M"
}

# Disk Read Alert Configuration
variable "disk_read_metric_name" {
  type        = string
  description = "Disk read metric name"
  default     = "Disk Read Operations/Sec"
}

variable "disk_read_aggregation" {
  type        = string
  description = "Disk read metric aggregation type"
  default     = "Average"
}

variable "disk_read_operator" {
  type        = string
  description = "Disk read alert operator"
  default     = "GreaterThan"
}

variable "disk_read_window_size" {
  type        = string
  description = "Disk read alert evaluation window size"
  default     = "PT5M"
}

variable "disk_read_frequency" {
  type        = string
  description = "Disk read alert evaluation frequency"
  default     = "PT1M"
}

# Disk Write Alert Configuration
variable "disk_write_metric_name" {
  type        = string
  description = "Disk write metric name"
  default     = "Disk Write Operations/Sec"
}

variable "disk_write_aggregation" {
  type        = string
  description = "Disk write metric aggregation type"
  default     = "Average"
}

variable "disk_write_operator" {
  type        = string
  description = "Disk write alert operator"
  default     = "GreaterThan"
}

variable "disk_write_window_size" {
  type        = string
  description = "Disk write alert evaluation window size"
  default     = "PT5M"
}

variable "disk_write_frequency" {
  type        = string
  description = "Disk write alert evaluation frequency"
  default     = "PT1M"
}

# Network In Alert Configuration
variable "network_in_metric_name" {
  type        = string
  description = "Network inbound metric name"
  default     = "Network In Total"
}

variable "network_in_aggregation" {
  type        = string
  description = "Network inbound metric aggregation type"
  default     = "Total"
}

variable "network_in_operator" {
  type        = string
  description = "Network inbound alert operator"
  default     = "GreaterThan"
}

variable "network_in_window_size" {
  type        = string
  description = "Network inbound alert evaluation window size"
  default     = "PT15M"
}

variable "network_in_frequency" {
  type        = string
  description = "Network inbound alert evaluation frequency"
  default     = "PT5M"
}

# Activity Log Alert Configuration
variable "activity_log_category_administrative" {
  type        = string
  description = "Activity log category for administrative operations"
  default     = "Administrative"
}

variable "activity_log_category_service_health" {
  type        = string
  description = "Activity log category for service health"
  default     = "ServiceHealth"
}

variable "vm_deallocate_operation_name" {
  type        = string
  description = "Operation name for VM deallocation"
  default     = "Microsoft.Compute/virtualMachines/deallocate/action"
}

variable "vm_poweroff_operation_name" {
  type        = string
  description = "Operation name for VM power off"
  default     = "Microsoft.Compute/virtualMachines/powerOff/action"
}

variable "vm_deallocated_description" {
  type        = string
  description = "Description for VM deallocation alert"
  default     = "Alert when VM is deallocated or stopped"
}

variable "vm_health_description" {
  type        = string
  description = "Description for VM health alert"
  default     = "Alert on VM health status changes"
}

variable "vm_health_level" {
  type        = string
  description = "VM health alert level"
  default     = "Error"
}

