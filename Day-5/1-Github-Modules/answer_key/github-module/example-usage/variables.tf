variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "github-module-test-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "testvm"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "Terraform"
    Module      = "GitHub"
  }
}

variable "public_ip_allocation_method" {
  description = "Allocation method for Public IP (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "SKU for Public IP (Basic or Standard)"
  type        = string
  default     = "Basic"
}

variable "os_disk_caching" {
  description = "OS disk caching type"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Standard_LRS"
}

variable "nsg_rules" {
  description = "Custom NSG rules (optional, uses defaults if not provided)"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = string
    source_address_prefix      = optional(string, "*")
    destination_address_prefix = optional(string, "*")
  }))
  default = null  # null means use module defaults
}

