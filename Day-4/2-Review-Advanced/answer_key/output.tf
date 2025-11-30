# Resource Group Output
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# Virtual Network Outputs
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

# Subnet Outputs using for_each
output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value = {
    for k, v in azurerm_subnet.main : k => v.id
  }
}

output "subnet_names" {
  description = "Map of subnet keys to subnet names"
  value = {
    for k, v in azurerm_subnet.main : k => v.name
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value = {
    for k, v in azurerm_subnet.main : k => v.address_prefixes
  }
}

# Network Security Group Outputs
output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.main.name
}

# Formatted Network Information
output "network_summary" {
  description = "Formatted summary of network infrastructure"
  value = {
    vnet = {
      name          = azurerm_virtual_network.main.name
      id            = azurerm_virtual_network.main.id
      address_space = azurerm_virtual_network.main.address_space
    }
    subnets = {
      for k, v in azurerm_subnet.main : k => {
        name            = v.name
        id              = v.id
        address_prefix  = v.address_prefixes[0]
        nsg_enabled     = var.subnets[k].nsg_enabled
        nsg_id          = var.subnets[k].nsg_enabled ? azurerm_network_security_group.main.id : null
      }
    }
    nsg = {
      name = azurerm_network_security_group.main.name
      id   = azurerm_network_security_group.main.id
      rules = {
        for k, v in var.nsg_rules : k => {
          priority              = v.priority
          direction             = v.direction
          access                = v.access
          protocol              = v.protocol
          destination_port      = v.destination_port_range
          source_address_prefix = v.source_address_prefix
        }
      }
    }
  }
}

# Environment Information
output "environment_info" {
  description = "Environment and naming information"
  value = {
    environment        = var.environment
    location           = var.location
    project_name       = var.project_name
    name_prefix        = local.name_prefix
    normalized_project = local.normalized_project_name
  }
}

