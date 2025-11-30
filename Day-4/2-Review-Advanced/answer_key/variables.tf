variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope", "centralus"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "project_name" {
  description = "Project name prefix for resource naming"
  type        = string
  default     = "myproject"
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters."
  }
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create. Key is subnet name, value contains configuration."
  type = map(object({
    address_prefix    = string
    service_endpoints = list(string)
    nsg_enabled       = bool
  }))
  
  default = {
    "frontend" = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
      nsg_enabled       = true
    }
    "backend" = {
      address_prefix    = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
      nsg_enabled       = true
    }
    "database" = {
      address_prefix    = "10.0.3.0/24"
      service_endpoints = []
      nsg_enabled       = false
    }
  }
  
  validation {
    condition = alltrue([
      for k, v in var.subnets : can(cidrhost(v.address_prefix, 0))
    ])
    error_message = "All subnet address_prefix values must be valid CIDR notation."
  }
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["*"]  # WARNING: Allows from anywhere - restrict in production!
}

variable "nsg_rules" {
  description = "Map of Network Security Group rules. Key is rule name."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = string
  }))
  
  default = {
    "AllowSSH" = {
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH from anywhere"
    }
    "AllowHTTP" = {
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP from internet"
    }
    "AllowHTTPS" = {
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from internet"
    }
  }
  
  validation {
    condition = alltrue([
      for k, v in var.nsg_rules : v.priority >= 100 && v.priority <= 4096
    ])
    error_message = "NSG rule priority must be between 100 and 4096."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.nsg_rules : contains(["Inbound", "Outbound"], v.direction)
    ])
    error_message = "NSG rule direction must be Inbound or Outbound."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.nsg_rules : contains(["Allow", "Deny"], v.access)
    ])
    error_message = "NSG rule access must be Allow or Deny."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "NetworkInfrastructure"
  }
}

