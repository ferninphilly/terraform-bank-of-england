terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Use VM module from GitHub
# Replace YOUR_USERNAME with your actual GitHub username
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  vm_size            = var.vm_size
  admin_username     = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  
  # Optional: Configure Public IP
  public_ip_allocation_method = var.public_ip_allocation_method
  public_ip_sku              = var.public_ip_sku
  
  # Optional: Configure OS Disk
  os_disk_caching              = var.os_disk_caching
  os_disk_storage_account_type = var.os_disk_storage_account_type
  
  # Optional: Custom NSG Rules (if provided, overrides defaults)
  nsg_rules = var.nsg_rules
  
  tags = var.tags
}

