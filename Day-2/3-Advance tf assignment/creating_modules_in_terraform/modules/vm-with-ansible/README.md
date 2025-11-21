# VM with Ansible Module

This module creates an Azure Linux Virtual Machine with network infrastructure and optional Ansible provisioning.

## What This Module Creates

- Virtual Network and Subnet
- Network Security Group (allows SSH and HTTP)
- Public IP Address
- Network Interface
- Linux Virtual Machine (Ubuntu 22.04)
- SSH Key Pair (generated automatically)
- Optional Ansible provisioning (nginx, docker)

## Usage

```hcl
module "my_vm" {
  source = "./modules/vm-with-ansible"
  
  name_prefix        = "web"
  resource_group_name = azurerm_resource_group.main.name
  location           = "eastus"
  environment        = "dev"
}
```

## Required Variables

- `name_prefix` - Prefix for resource names
- `resource_group_name` - Existing resource group name
- `location` - Azure region

## Optional Variables

- `environment` - Environment (dev/staging/prod), defaults to "dev"
- `vm_size` - VM size, defaults based on environment
- `enable_ansible` - Enable Ansible provisioning, defaults to true
- `install_nginx` - Install nginx, defaults to true
- `install_docker` - Install Docker, defaults to false

## Outputs

- `vm_public_ip` - Public IP address
- `vm_private_ip` - Private IP address
- `ssh_command` - SSH command to connect
- `vm_id` - VM resource ID
- `vnet_id` - Virtual network ID
- `subnet_id` - Subnet ID

## See Also

See the root `task.md` for detailed documentation and examples.

