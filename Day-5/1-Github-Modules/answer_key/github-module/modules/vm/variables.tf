variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "vm_size" {
  description = "Size of the virtual machine (e.g., Standard_B1s, Standard_B2s, Standard_D2s_v3)"
  type        = string
  default     = "Standard_B1s"
  
  validation {
    condition = can(regex("^Standard_[A-Z][0-9]+[a-z]*$", var.vm_size))
    error_message = "VM size must be a valid Azure VM size."
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

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "public_ip_allocation_method" {
  description = "Allocation method for Public IP (Static or Dynamic)"
  type        = string
  default     = "Static"
  
  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be Static or Dynamic."
  }
}

variable "public_ip_sku" {
  description = "SKU for Public IP (Basic or Standard)"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be Basic or Standard."
  }
}

variable "nsg_rules" {
  description = "Network Security Group rules. Each rule should have: name, priority, direction, access, protocol, destination_port_range, source_address_prefix"
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
  default = [
    {
      name                   = "AllowSSH"
      priority               = 1001
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "22"
    },
    {
      name                   = "AllowHTTP"
      priority               = 1002
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "80"
    }
  ]
}

variable "os_disk_caching" {
  description = "OS disk caching type"
  type        = string
  default     = "ReadWrite"
  
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be None, ReadOnly, or ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Standard_LRS"
  
  validation {
    condition = contains([
      "Standard_LRS",
      "Premium_LRS",
      "StandardSSD_LRS",
      "UltraSSD_LRS",
      "Premium_ZRS",
      "StandardSSD_ZRS"
    ], var.os_disk_storage_account_type)
    error_message = "OS disk storage account type must be a valid Azure disk type."
  }
}

variable "source_image_reference" {
  description = "Source image reference for the VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "disable_password_authentication" {
  description = "Disable password authentication (use SSH keys only)"
  type        = bool
  default     = true
}

variable "private_ip_address_allocation" {
  description = "Private IP address allocation method (Static or Dynamic)"
  type        = string
  default     = "Dynamic"
  
  validation {
    condition     = contains(["Static", "Dynamic"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be Static or Dynamic."
  }
}

variable "private_ip_address" {
  description = "Private IP address (required if private_ip_address_allocation is Static)"
  type        = string
  default     = null
}

