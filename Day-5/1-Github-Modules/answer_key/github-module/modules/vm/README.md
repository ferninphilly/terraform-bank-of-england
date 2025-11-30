# terraform-azurerm-vm

Terraform module for creating Azure Linux Virtual Machines with complete networking infrastructure.

## Features

- ✅ Virtual Network and Subnet creation
- ✅ Public IP Address allocation
- ✅ Network Security Group with SSH and HTTP rules
- ✅ Network Interface Card configuration
- ✅ Linux Virtual Machine (Ubuntu 22.04 LTS)
- ✅ Configurable VM sizes
- ✅ SSH key authentication

## Usage

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "myvm"
  resource_group_name = "my-rg"
  location           = "eastus"
  vm_size            = "Standard_B2s"
  admin_username     = "azureuser"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| vm_size | VM size (e.g., Standard_B2s) | `string` | `"Standard_B1s"` | no |
| admin_username | Admin username for VM | `string` | `"azureuser"` | no |
| ssh_public_key_path | Path to SSH public key file | `string` | `"~/.ssh/id_rsa.pub"` | no |
| vnet_address_space | Address space for Virtual Network | `list(string)` | `["10.0.0.0/16"]` | no |
| subnet_address_prefix | Address prefix for subnet | `string` | `"10.0.1.0/24"` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |
| public_ip_allocation_method | Allocation method for Public IP (Static or Dynamic) | `string` | `"Static"` | no |
| public_ip_sku | SKU for Public IP (Basic or Standard) | `string` | `"Basic"` | no |
| nsg_rules | Network Security Group rules | `list(object)` | See below | no |
| os_disk_caching | OS disk caching type | `string` | `"ReadWrite"` | no |
| os_disk_storage_account_type | OS disk storage account type | `string` | `"Standard_LRS"` | no |
| source_image_reference | Source image reference for the VM | `object` | Ubuntu 22.04 LTS | no |
| disable_password_authentication | Disable password authentication | `bool` | `true` | no |
| private_ip_address_allocation | Private IP allocation (Static or Dynamic) | `string` | `"Dynamic"` | no |
| private_ip_address | Private IP address (required if allocation is Static) | `string` | `null` | no |

### NSG Rules Default

By default, the module creates two NSG rules:
- **AllowSSH** (priority 1001): Allows inbound SSH on port 22
- **AllowHTTP** (priority 1002): Allows inbound HTTP on port 80

You can override this by providing custom rules in the `nsg_rules` variable.

## Outputs

| Name | Description |
|------|-------------|
| vm_id | ID of the virtual machine |
| vm_name | Name of the virtual machine |
| vm_public_ip | Public IP address of the VM |
| vm_private_ip | Private IP address of the VM |
| vnet_id | ID of the virtual network |
| subnet_id | ID of the subnet |
| nsg_id | ID of the network security group |
| resource_group_name | Resource group name |
| location | Location |

## Examples

### Basic Usage

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "webvm"
  resource_group_name = "web-rg"
  location           = "eastus"
}
```

### Custom VM Size

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "appvm"
  resource_group_name = "app-rg"
  location           = "eastus"
  vm_size            = "Standard_D2s_v3"
}
```

### Custom Network Configuration

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix         = "dbvm"
  resource_group_name = "db-rg"
  location            = "eastus"
  vnet_address_space  = ["192.168.0.0/16"]
  subnet_address_prefix = "192.168.1.0/24"
}
```

### Custom NSG Rules

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "webvm"
  resource_group_name = "web-rg"
  location           = "eastus"
  
  nsg_rules = [
    {
      name                   = "AllowSSH"
      priority               = 1001
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "22"
      source_address_prefix  = "203.0.113.0/24"  # Restrict SSH to specific IP range
    },
    {
      name                   = "AllowHTTPS"
      priority               = 1002
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "443"
    }
  ]
}
```

### Premium Disk and Custom Image

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "appvm"
  resource_group_name = "app-rg"
  location           = "eastus"
  vm_size            = "Standard_D2s_v3"
  
  os_disk_storage_account_type = "Premium_LRS"
  
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
```

### Standard Public IP with Static Private IP

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "appvm"
  resource_group_name = "app-rg"
  location           = "eastus"
  
  public_ip_sku                = "Standard"
  private_ip_address_allocation = "Static"
  private_ip_address           = "10.0.1.100"
}
```

## Resources Created

This module creates the following resources:

- `azurerm_virtual_network` - Virtual Network
- `azurerm_subnet` - Subnet
- `azurerm_public_ip` - Public IP Address
- `azurerm_network_security_group` - Network Security Group
- `azurerm_network_security_rule` - Security Rules (SSH, HTTP)
- `azurerm_network_interface` - Network Interface
- `azurerm_linux_virtual_machine` - Linux Virtual Machine

## Notes

- The module uses Ubuntu 22.04 LTS by default
- SSH key authentication is required
- Public IP is allocated statically
- Network Security Group allows SSH (22) and HTTP (80) by default

## License

MIT License

