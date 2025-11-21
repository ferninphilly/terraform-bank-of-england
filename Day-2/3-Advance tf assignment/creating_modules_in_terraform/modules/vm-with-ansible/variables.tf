variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g., 'web', 'app', 'db')"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where resources will be created"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
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
  description = "VM size. If empty, will use environment-based defaults (dev: B1s, staging: B2s, prod: B2ms)"
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
  description = "Path to Ansible playbook relative to module directory"
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
  description = "Tags to apply to all resources"
  default     = {}
}

# Random ID Configuration
variable "random_id_byte_length" {
  type        = number
  description = "Byte length for random ID suffix"
  default     = 4
}

# Network Configuration
variable "nsg_ssh_rule_name" {
  type        = string
  description = "Name for SSH security rule"
  default     = "allow-ssh"
}

variable "nsg_ssh_priority" {
  type        = number
  description = "Priority for SSH security rule"
  default     = 100
}

variable "nsg_http_rule_name" {
  type        = string
  description = "Name for HTTP security rule"
  default     = "allow-http"
}

variable "nsg_http_priority" {
  type        = number
  description = "Priority for HTTP security rule"
  default     = 110
}

variable "nsg_source_address_prefix" {
  type        = string
  description = "Source address prefix for NSG rules"
  default     = "*"
}

variable "ssh_port" {
  type        = number
  description = "SSH port number"
  default     = 22
}

variable "http_port" {
  type        = number
  description = "HTTP port number"
  default     = 80
}

variable "public_ip_allocation_method" {
  type        = string
  description = "Public IP allocation method"
  default     = "Static"
}

variable "public_ip_sku" {
  type        = string
  description = "Public IP SKU"
  default     = "Standard"
}

variable "nic_ip_config_name" {
  type        = string
  description = "Name for network interface IP configuration"
  default     = "internal"
}

variable "nic_private_ip_allocation" {
  type        = string
  description = "Private IP allocation method for NIC"
  default     = "Dynamic"
}

# SSH Key Configuration
variable "ssh_key_algorithm" {
  type        = string
  description = "SSH key algorithm"
  default     = "RSA"
}

variable "ssh_key_rsa_bits" {
  type        = number
  description = "RSA key bits"
  default     = 4096
}

variable "ssh_private_key_permissions" {
  type        = string
  description = "File permissions for private key"
  default     = "0600"
}

# VM Configuration
variable "vm_size_dev" {
  type        = string
  description = "Default VM size for dev environment"
  default     = "Standard_B1s"
}

variable "vm_size_staging" {
  type        = string
  description = "Default VM size for staging environment"
  default     = "Standard_B2s"
}

variable "vm_size_prod" {
  type        = string
  description = "Default VM size for prod environment"
  default     = "Standard_B2ms"
}

variable "disable_password_authentication" {
  type        = bool
  description = "Disable password authentication for VM"
  default     = true
}

variable "os_disk_caching" {
  type        = string
  description = "OS disk caching type"
  default     = "ReadWrite"
}

variable "storage_account_type_dev" {
  type        = string
  description = "Storage account type for dev/staging"
  default     = "Standard_LRS"
}

variable "storage_account_type_prod" {
  type        = string
  description = "Storage account type for prod"
  default     = "Premium_LRS"
}

variable "vm_image_publisher" {
  type        = string
  description = "VM image publisher"
  default     = "Canonical"
}

variable "vm_image_offer" {
  type        = string
  description = "VM image offer"
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  type        = string
  description = "VM image SKU"
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  type        = string
  description = "VM image version"
  default     = "latest"
}

variable "enable_boot_diagnostics" {
  type        = bool
  description = "Enable boot diagnostics"
  default     = false
}

variable "module_tag" {
  type        = string
  description = "Tag value for module identification"
  default     = "vm-with-ansible"
}

variable "remote_exec_inline_commands" {
  type        = list(string)
  description = "Commands to run in remote-exec provisioner"
  default     = [
    "echo 'VM is ready for Ansible provisioning'",
    "sudo apt-get update",
  ]
}

variable "ansible_python_interpreter" {
  type        = string
  description = "Python interpreter path for Ansible"
  default     = "/usr/bin/python3"
}

variable "ansible_skip_message" {
  type        = string
  description = "Message to display when Ansible is skipped"
  default     = "echo 'Ansible provisioning skipped'"
}

# Alert Configuration (for use in locals)
variable "alert_severity_prod" {
  type        = number
  description = "Alert severity for production environment"
  default     = 2
}

variable "alert_severity_dev" {
  type        = number
  description = "Alert severity for dev/staging environment"
  default     = 3
}

