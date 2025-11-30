# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.resource_names.vnet
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Subnets using for_each
resource "azurerm_subnet" "main" {
  for_each = var.subnets
  
  name                 = local.subnet_names[each.key]
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints

  # Note: NSG association is done separately below
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = local.resource_names.nsg
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Dynamic block for security rules using for_each
  dynamic "security_rule" {
    for_each = var.nsg_rules
    
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }

  tags = local.common_tags
}

# Associate NSG with subnets that have nsg_enabled = true
# Using for_each to only create associations for subnets that need NSG
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = local.subnets_with_nsg
  
  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main.id
}

