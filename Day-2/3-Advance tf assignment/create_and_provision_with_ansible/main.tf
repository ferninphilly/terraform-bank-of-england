# Generate random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# Data source to get current subscription
data "azurerm_subscription" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}-${random_id.suffix.hex}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.environment}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow SSH
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP (for nginx)
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
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
  name                = "pip-${var.environment}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-${var.environment}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = var.tags
}

# Generate SSH key pair (for demonstration - in production, use existing keys)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally (for Ansible)
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/.ssh/id_rsa"
  file_permission = "0600"
}

# Save public key locally
resource "local_file" "public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${path.module}/.ssh/id_rsa.pub"
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${var.environment}-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  # Ternary operator: Use environment-based VM size if vm_size not specified
  size = var.vm_size != "" ? var.vm_size : (
    var.environment == "prod" ? "Standard_B2ms" : (
      var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
    )
  )

  admin_username = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Disable password authentication, use SSH keys
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  # OS Disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
  }

  # Source Image - Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = null
  }

  tags = merge(var.tags, {
    Environment = var.environment
    VM_Size    = var.vm_size != "" ? var.vm_size : (
      var.environment == "prod" ? "Standard_B2ms" : (
        var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
      )
    )
  })

  # Ansible Provisioner
  # Only runs if enable_ansible is true
  provisioner "remote-exec" {
    inline = [
      "echo 'VM is ready for Ansible provisioning'",
      "sudo apt-get update",
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = tls_private_key.ssh.private_key_pem
      host        = azurerm_public_ip.main.ip_address
    }
  }

  # Ansible Local Provisioner
  # This runs Ansible from your local machine
  provisioner "local-exec" {
    command = var.enable_ansible ? <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i ${azurerm_public_ip.main.ip_address}, \
        -u ${var.admin_username} \
        --private-key ${path.module}/.ssh/id_rsa \
        -e "ansible_python_interpreter=/usr/bin/python3" \
        -e "install_nginx=${var.install_nginx}" \
        -e "install_docker=${var.install_docker}" \
        ${var.ansible_playbook_path}
    EOT : "echo 'Ansible provisioning skipped'"
  }

  depends_on = [
    azurerm_network_interface.main,
    local_file.private_key,
  ]
}

# Output values
output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i ${path.module}/.ssh/id_rsa ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "vm_size_used" {
  description = "VM size that was actually used"
  value = var.vm_size != "" ? var.vm_size : (
    var.environment == "prod" ? "Standard_B2ms" : (
      var.environment == "staging" ? "Standard_B2s" : "Standard_B1s"
    )
  )
}

output "ansible_status" {
  description = "Whether Ansible provisioning was enabled"
  value       = var.enable_ansible ? "Enabled" : "Disabled"
}

