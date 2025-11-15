# main.tf

# --- 1. Providers and Setup ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Provider block is empty, relying on environment variables for authentication
provider "azurerm" {
  features {}
}

# --- 2. Resource Group and Networking ---
resource "azurerm_resource_group" "rg_lesson" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-lesson"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_lesson.location
  resource_group_name = azurerm_resource_group.rg_lesson.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-lesson"
  resource_group_name  = azurerm_resource_group.rg_lesson.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# --- 3. Public IP, NIC, and SSH Rule ---

# Public IP Address (Allows outside access)
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-lesson"
  location            = azurerm_resource_group.rg_lesson.location
  resource_group_name = azurerm_resource_group.rg_lesson.name
  allocation_method   = "Dynamic"
}

# Network Security Group (NSG) Rule to open port 22 (SSH)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-lesson"
  location            = azurerm_resource_group.rg_lesson.location
  resource_group_name = azurerm_resource_group.rg_lesson.name

  security_rule {
    name                       = "SSH_Inbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet" # Opens to all public IPs - caution for production!
    destination_address_prefix = "*"
  }
}

# Network Interface Card (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "nic-lesson"
  location            = azurerm_resource_group.rg_lesson.location
  resource_group_name = azurerm_resource_group.rg_lesson.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Association to link the SSH rule (NSG) to the NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_associate" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# --- 4. The LINUX Virtual Machine (VM) ---
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "smallest-linux-vm"
  resource_group_name   = azurerm_resource_group.rg_lesson.name
  location              = azurerm_resource_group.rg_lesson.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  disable_password_authentication = true

  # Inject the SSH Public Key (reading the key generated in the previous step)
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/azure-vm-key.pub")
  }

  # Image Source: Ubuntu 20.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}