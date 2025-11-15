# Task for Day-2 Step 4 - More Hands On: VNet Peering with Bastion Host

This module focuses on implementing VNet peering, using variables, bastion hosts, and the `count` meta-argument to create multiple VMs efficiently.

## Learning Objectives

By completing this task, you will learn:
- How to use Terraform variables to make configurations reusable
- How to implement Azure Bastion Host for secure VM access
- How to use `count` and `count.index` to create multiple resources efficiently
- How to configure VNet peering between two virtual networks
- How to test network connectivity with and without peering

## Assignment Requirements

1. **Use Variables**: Refactor hardcoded values to use variables
2. **Use Bastion Host**: Implement Azure Bastion Host for secure VM access
3. **Use Count for VMs**: Refactor VM creation to use `count` and `count.index`
4. **Test Connection Without Peering**: Verify VMs cannot communicate before peering
5. **Test Connection With Peering**: Verify VMs can communicate after peering

## Step-by-Step Instructions

### Step 1: Create Variables File

Create a `variables.tf` file to define all configurable values:

```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "day15-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "testadmin"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
  default     = "Password1234!"
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_DS1_v2"
}
```

### Step 2: Refactor Network Configuration to Use Variables

Update `network.tf` to use variables:

1. Replace hardcoded resource group name with `var.resource_group_name`
2. Replace hardcoded location with `var.location`
3. Consider making VNet address spaces configurable (optional)

**Example changes:**
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
```

### Step 3: Create Bastion Host Subnet and Configuration

Add a bastion subnet to each VNet in `network.tf`:

```hcl
# Bastion subnet for VNet 1
resource "azurerm_subnet" "bastion1" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/27"]  # Must be /27 or larger
}

# Bastion subnet for VNet 2
resource "azurerm_subnet" "bastion2" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.1.0/27"]  # Must be /27 or larger
}

# Public IP for Bastion 1
resource "azurerm_public_ip" "bastion1" {
  name                = "bastion1-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Public IP for Bastion 2
resource "azurerm_public_ip" "bastion2" {
  name                = "bastion2-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion Host 1
resource "azurerm_bastion_host" "bastion1" {
  name                = "bastion1-host"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion1.id
    public_ip_address_id = azurerm_public_ip.bastion1.id
  }
}

# Bastion Host 2
resource "azurerm_bastion_host" "bastion2" {
  name                = "bastion2-host"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion2.id
    public_ip_address_id = azurerm_public_ip.bastion2.id
  }
}
```

### Step 4: Refactor VM Configuration to Use Count

Refactor `vm.tf` to use `count` for creating multiple VMs:

1. Create a list or map structure to hold VM configuration
2. Use `count` to iterate and create VMs
3. Use `count.index` to reference specific values

**Example approach:**

```hcl
# Local values for VM configuration
locals {
  vms = [
    {
      name              = "peer1-vm"
      vnet_name         = azurerm_virtual_network.vnet1.name
      subnet_id         = azurerm_subnet.sn1.id
      private_ip_prefix = "10.0.0"
      environment       = "staging"
    },
    {
      name              = "peer2-vm"
      vnet_name         = azurerm_virtual_network.vnet2.name
      subnet_id         = azurerm_subnet.sn2.id
      private_ip_prefix = "10.1.0"
      environment       = "dev"
    }
  ]
}

# Network interfaces using count
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${local.vms[count.index].name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration${count.index + 1}"
    subnet_id                     = local.vms[count.index].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual machines using count
resource "azurerm_virtual_machine" "main" {
  count                 = var.vm_count
  name                  = local.vms[count.index].name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "myosdisk${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name  = "hostname${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags = {
    environment = local.vms[count.index].environment
  }
}
```

### Step 5: Enable VNet Peering

Uncomment and update the peering resources in `network.tf`:

```hcl
resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  allow_virtual_network_access = true
}
```

### Step 6: Create Outputs File

Create `output.tf` to display useful information:

```hcl
output "vm_private_ips" {
  description = "Private IP addresses of the VMs"
  value       = azurerm_network_interface.main[*].private_ip_address
}

output "bastion_public_ips" {
  description = "Public IP addresses of the Bastion hosts"
  value = {
    bastion1 = azurerm_public_ip.bastion1.ip_address
    bastion2 = azurerm_public_ip.bastion2.ip_address
  }
}

output "vm_names" {
  description = "Names of the created VMs"
  value       = azurerm_virtual_machine.main[*].name
}
```

### Step 7: Initialize and Plan

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Verify that:
   - Variables are being used correctly
   - Count is creating 2 VMs
   - Bastion hosts are being created
   - VNet peering is configured

### Step 8: Deploy Infrastructure (Without Peering First)

**IMPORTANT**: Initially, keep the peering resources commented out to test connectivity without peering.

1. Apply the configuration:
   ```bash
   terraform apply
   ```

2. Wait for all resources to be created (this may take 10-15 minutes)

### Step 9: Test Connection Without Peering

1. **Get VM Private IPs**:
   ```bash
   terraform output vm_private_ips
   ```

2. **Connect to VM1 via Bastion**:
   - Go to Azure Portal
   - Navigate to `peer1-vm`
   - Click "Connect" → "Bastion"
   - Enter credentials: `testadmin` / `Password1234!`

3. **Test Connectivity to VM2**:
   From VM1, try to ping VM2:
   ```bash
   ping <VM2_PRIVATE_IP>
   ```
   **Expected Result**: Ping should fail because VNets are not peered

4. **Verify Network Isolation**:
   ```bash
   # Check network interfaces
   ip addr show
   
   # Try to connect via SSH (should fail)
   ssh testadmin@<VM2_PRIVATE_IP>
   ```

### Step 10: Enable VNet Peering

1. **Uncomment peering resources** in `network.tf`

2. **Apply the changes**:
   ```bash
   terraform apply
   ```

3. **Wait for peering to complete** (usually takes 1-2 minutes)

4. **Verify peering status** in Azure Portal:
   - Navigate to `peer1-vnet` → Peerings
   - Verify status shows "Connected"

### Step 11: Test Connection With Peering

1. **Reconnect to VM1 via Bastion** (same as Step 9)

2. **Test Connectivity to VM2**:
   From VM1, ping VM2:
   ```bash
   ping <VM2_PRIVATE_IP>
   ```
   **Expected Result**: Ping should succeed

3. **Test SSH Connection**:
   ```bash
   ssh testadmin@<VM2_PRIVATE_IP>
   ```
   **Expected Result**: SSH connection should succeed

4. **Test Reverse Connectivity**:
   - Connect to VM2 via Bastion
   - Ping VM1 from VM2
   - Verify bidirectional connectivity

5. **Test Network Tools**:
   ```bash
   # Test HTTP connectivity (if web server is running)
   curl http://<VM2_PRIVATE_IP>
   
   # Check routing table
   ip route show
   ```

### Step 12: Verification Checklist

- [ ] Variables are defined and used throughout the configuration
- [ ] Bastion hosts are created and accessible
- [ ] VMs are created using `count` and `count.index`
- [ ] VMs cannot communicate before peering (tested)
- [ ] VNet peering is configured and connected
- [ ] VMs can communicate after peering (tested)
- [ ] All resources are properly tagged
- [ ] Outputs display correct information

## Troubleshooting

### Common Issues:

1. **Bastion subnet must be named "AzureBastionSubnet"**
   - This is a requirement by Azure

2. **Bastion subnet must be /27 or larger**
   - Minimum size requirement

3. **Peering fails to connect**
   - Ensure both peering resources are created (bidirectional)
   - Check that VNets are in the same region
   - Verify no overlapping address spaces

4. **VMs still can't communicate after peering**
   - Check NSG rules (if any)
   - Verify peering status is "Connected" in Azure Portal
   - Ensure `allow_virtual_network_access = true`

5. **Count index errors**
   - Ensure `count.index` matches the array/list length
   - Verify all referenced resources exist

## Cleanup

When finished, destroy all resources:

```bash
terraform destroy
```

## Key Concepts Learned

- **Variables**: Making Terraform configurations reusable and maintainable
- **Count**: Creating multiple similar resources efficiently
- **Count.index**: Accessing specific values in a list during iteration
- **Bastion Host**: Secure way to access VMs without public IPs
- **VNet Peering**: Connecting virtual networks for cross-network communication
- **Network Testing**: Verifying connectivity before and after configuration changes

## Files in this directory:

- `main.tf` - (Not present, resources split into network.tf and vm.tf)
- `network.tf` - Network resources (VNets, subnets, peering)
- `vm.tf` - Virtual machine resources
- `variables.tf` - Variable definitions (to be created)
- `output.tf` - Output definitions (to be created)
- `backend.tf` - Backend configuration
- `provider.tf` - Provider configuration
- `readme.md` - Assignment requirements
- `task.md` - This file

## Next Steps

After completing this task, consider:
- Adding Network Security Groups (NSGs) to control traffic
- Implementing `for_each` instead of `count` for more flexibility
- Adding conditional logic for peering
- Creating a module for reusable VM creation
- Adding monitoring and logging

