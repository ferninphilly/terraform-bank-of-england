variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vm-module-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "myvm"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
  
  validation {
    condition = can(regex("^Standard_[A-Z][0-9]+[a-z]*$", var.vm_size))
    error_message = "VM size must be a valid Azure VM size (e.g., Standard_B1s, Standard_B2s, Standard_D2s_v3)."
  }
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
  
  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "enable_alerts" {
  description = "Whether to enable monitoring alerts"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address to receive alert notifications"
  type        = string
  default     = ""
}

variable "cpu_threshold_percent" {
  description = "CPU usage threshold percentage for alerts"
  type        = number
  default     = 80
  
  validation {
    condition     = var.cpu_threshold_percent > 0 && var.cpu_threshold_percent <= 100
    error_message = "CPU threshold must be between 1 and 100 percent."
  }
}

variable "memory_threshold_percent" {
  description = "Memory usage threshold percentage for alerts"
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
  default = {
    Environment = "dev"
    Project     = "VM-Module-Example"
    ManagedBy   = "Terraform"
  }
}

