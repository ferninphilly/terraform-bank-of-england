# Generate random suffix for unique naming within module
resource "random_id" "suffix" {
  byte_length = var.random_id_byte_length
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet-${random_id.suffix.hex}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.name_prefix}-nsg-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow SSH
  security_rule {
    name                       = var.nsg_ssh_rule_name
    priority                   = var.nsg_ssh_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.ssh_port
    source_address_prefix      = var.nsg_source_address_prefix
    destination_address_prefix = "*"
  }

  # Allow HTTP (for nginx)
  security_rule {
    name                       = var.nsg_http_rule_name
    priority                   = var.nsg_http_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.http_port
    source_address_prefix      = var.nsg_source_address_prefix
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-pip-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = var.tags
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.name_prefix}-nic-${random_id.suffix.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.nic_ip_config_name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = var.nic_private_ip_allocation
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = var.tags
}

