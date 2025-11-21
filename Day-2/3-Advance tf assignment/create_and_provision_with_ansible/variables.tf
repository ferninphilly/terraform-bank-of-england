variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "vm-ansible-rg"
}

variable "vm_size" {
  type        = string
  description = "VM size (will be overridden by environment-based logic)"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
  sensitive   = true
}

variable "enable_ansible" {
  type        = bool
  description = "Whether to run Ansible provisioner"
  default     = true
}

variable "ansible_playbook_path" {
  type        = string
  description = "Path to Ansible playbook"
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
    Project     = "Terraform-Ansible"
    ManagedBy   = "Terraform"
    Provisioner = "Ansible"
  }
}

