variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "modules-demo-rg"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "eastus"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (passed to module)"
  default     = "web"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vm_size" {
  type        = string
  description = "VM size. Leave empty to use environment-based defaults"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
  sensitive   = true
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the subnet"
  default     = ["10.0.1.0/24"]
}

variable "enable_ansible" {
  type        = bool
  description = "Whether to run Ansible provisioner"
  default     = true
}

variable "ansible_playbook_path" {
  type        = string
  description = "Path to Ansible playbook (relative to module directory)"
  default     = "ansible/playbook.yml"
}

variable "install_nginx" {
  type        = bool
  description = "Whether to install nginx via Ansible"
  default     = true
}

variable "install_docker" {
  type        = bool
  description = "Whether to install Docker via Ansible"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default = {
    Project     = "Terraform-Modules"
    ManagedBy   = "Terraform"
    Provisioner = "Ansible"
  }
}

# Module Tag Variables
variable "module_tag_web_vm" {
  type        = string
  description = "Tag value for web VM module"
  default     = "web-vm"
}

variable "module_tag_alerts" {
  type        = string
  description = "Tag value for alerts module"
  default     = "vm-alerts"
}

# Alert Configuration Variables
variable "enable_alerts" {
  type        = bool
  description = "Whether to enable VM monitoring alerts"
  default     = true
}

variable "alert_email" {
  type        = string
  description = "Email address to receive alert notifications (leave empty to disable email alerts)"
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
  description = "Disk usage threshold percentage for alerts"
  default     = 90
}

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

