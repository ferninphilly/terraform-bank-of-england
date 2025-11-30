variable "vm_id" {
  description = "ID of the VM to monitor"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for alert names"
  type        = string
}

variable "enable_alerts" {
  description = "Whether to enable alerts"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = ""
}

variable "cpu_threshold_percent" {
  description = "CPU usage threshold percentage"
  type        = number
  default     = 80
  
  validation {
    condition     = var.cpu_threshold_percent > 0 && var.cpu_threshold_percent <= 100
    error_message = "CPU threshold must be between 1 and 100 percent."
  }
}

variable "memory_threshold_percent" {
  description = "Memory usage threshold percentage"
  type        = number
  default     = 85
  
  validation {
    condition     = var.memory_threshold_percent > 0 && var.memory_threshold_percent <= 100
    error_message = "Memory threshold must be between 1 and 100 percent."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

