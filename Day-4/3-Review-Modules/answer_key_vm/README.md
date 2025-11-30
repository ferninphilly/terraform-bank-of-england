# Answer Key: VM Module with Alerts

This directory contains a complete working example of a Virtual Machine module with monitoring alerts and configurable VM sizes.

## Overview

This example demonstrates:
- ✅ Creating a complete VM module with networking
- ✅ Passing configurable VM sizes via variables
- ✅ Creating a separate alerts module
- ✅ Module dependencies (alerts depend on VM)
- ✅ Using module outputs to connect modules
- ✅ Conditional resource creation (alerts)

## Directory Structure

```
answer_key_vm/
├── backend.tf                    # Backend configuration
├── provider.tf                   # Provider configuration
├── variables.tf                  # Root module variables
├── main.tf                       # Root module (uses VM and alerts modules)
├── output.tf                     # Root module outputs
├── terraform.tfvars.example      # Example variable values
└── modules/
    ├── vm/
    │   ├── variables.tf          # VM module variables
    │   ├── main.tf              # VM and networking resources
    │   └── outputs.tf           # VM module outputs
    └── vm-alerts/
        ├── variables.tf          # Alerts module variables
        ├── main.tf              # Alert resources
        └── outputs.tf           # Alerts module outputs
```

## Module Architecture

### VM Module (`modules/vm/`)

**Creates:**
- Virtual Network
- Subnet
- Public IP Address
- Network Security Group (with SSH and HTTP rules)
- Network Interface
- Linux Virtual Machine

**Key Features:**
- Configurable VM size via `vm_size` variable
- Complete networking setup
- SSH key authentication
- Ubuntu 22.04 LTS image

### Alerts Module (`modules/vm-alerts/`)

**Creates:**
- Action Group (for email notifications)
- CPU Usage Alert (when CPU > threshold)
- Memory Alert (when available memory is low)

**Key Features:**
- Conditional creation (can be disabled)
- Configurable thresholds
- Email notifications (optional)

## How It Works

### 1. Root Module Calls VM Module

```hcl
module "vm" {
  source = "./modules/vm"
  
  name_prefix        = var.name_prefix
  resource_group_name = var.resource_group_name
  location           = var.location
  vm_size            = var.vm_size  # Configurable!
  # ... other variables
}
```

**What Happens:**
- VM module creates all networking and VM resources
- VM module outputs VM ID, name, IPs, etc.

### 2. Root Module Calls Alerts Module

```hcl
module "vm_alerts" {
  source = "./modules/vm-alerts"
  count  = var.enable_alerts ? 1 : 0
  
  vm_id                  = module.vm.vm_id      # Uses VM module output!
  vm_name                = module.vm.vm_name
  resource_group_name    = module.vm.resource_group_name
  # ... other variables
}
```

**What Happens:**
- Alerts module uses VM module outputs
- Creates alerts that monitor the VM
- Conditionally created (can be disabled)

### 3. Module Dependency Flow

```
Root Module
    ↓
VM Module (creates VM)
    ↓ (outputs: vm_id, vm_name)
Alerts Module (creates alerts for VM)
```

## Variable Flow

```
Root Variables (variables.tf)
    ↓
VM Module (main.tf)
    ↓
VM Module Variables (modules/vm/variables.tf)
    ↓
VM Resources (modules/vm/main.tf)
    ↓
VM Module Outputs (modules/vm/outputs.tf)
    ↓
Root Module (main.tf - alerts module)
    ↓
Alerts Module Variables (modules/vm-alerts/variables.tf)
    ↓
Alert Resources (modules/vm-alerts/main.tf)
```

## Usage

### 1. Copy Example Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Variables

Edit `terraform.tfvars`:

```hcl
# Change VM size
vm_size = "Standard_B2s"  # 2 vCPU, 4GB RAM

# Configure alerts
enable_alerts = true
alert_email   = "your-email@example.com"
cpu_threshold_percent = 75  # Alert at 75% CPU
```

### 3. Initialize Terraform

```bash
terraform init
```

This initializes both modules.

### 4. Review Plan

```bash
terraform plan
```

**Expected Resources:**
- 1 Virtual Network
- 1 Subnet
- 1 Public IP
- 1 Network Security Group
- 1 Network Interface
- 1 Linux Virtual Machine
- 1 Action Group (if alerts enabled and email provided)
- 2 Metric Alerts (CPU and Memory, if alerts enabled)

### 5. Apply Configuration

```bash
terraform apply
```

### 6. View Outputs

```bash
terraform output
```

**Expected Outputs:**
```
vm_id = "/subscriptions/.../virtualMachines/myvm-vm"
vm_name = "myvm-vm"
vm_public_ip = "20.123.45.67"
ssh_command = "ssh azureuser@20.123.45.67"
alerts_enabled = true
```

## Configuring VM Sizes

### Common VM Sizes

**Burstable (B-series)** - Good for development/testing:
- `Standard_B1s` - 1 vCPU, 1GB RAM (cheapest)
- `Standard_B2s` - 2 vCPU, 4GB RAM

**General Purpose (D-series)** - Good for production:
- `Standard_D2s_v3` - 2 vCPU, 8GB RAM
- `Standard_D4s_v3` - 4 vCPU, 16GB RAM

**Change VM Size:**

```hcl
# In terraform.tfvars
vm_size = "Standard_D2s_v3"  # Change from default Standard_B1s
```

## Configuring Alerts

### Enable/Disable Alerts

```hcl
# Disable alerts
enable_alerts = false

# Enable alerts
enable_alerts = true
```

### Configure Alert Thresholds

```hcl
# Alert when CPU > 75%
cpu_threshold_percent = 75

# Alert when memory usage > 90%
memory_threshold_percent = 90
```

### Email Notifications

```hcl
# Set email for notifications
alert_email = "admin@example.com"

# Leave empty to disable email notifications (alerts still created)
alert_email = ""
```

## Understanding Module Dependencies

### Why Alerts Module Depends on VM Module

```hcl
# VM module creates VM first
module "vm" {
  # Creates VM and outputs vm_id
}

# Alerts module uses VM output
module "vm_alerts" {
  vm_id = module.vm.vm_id  # Must wait for VM to be created
}
```

**Terraform automatically handles:**
- Creating VM module first
- Then creating alerts module
- Proper dependency ordering

## Key Concepts Demonstrated

### 1. Configurable VM Sizes

```hcl
# Root variable
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

# Pass to module
module "vm" {
  vm_size = var.vm_size  # Configurable!
}
```

### 2. Module Outputs

```hcl
# VM module outputs
output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}

# Use in alerts module
module "vm_alerts" {
  vm_id = module.vm.vm_id  # Uses VM output
}
```

### 3. Conditional Module Creation

```hcl
module "vm_alerts" {
  source = "./modules/vm-alerts"
  count  = var.enable_alerts ? 1 : 0  # Conditional!
  # ...
}
```

### 4. Conditional Resources in Module

```hcl
# In alerts module
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts && var.alert_email != "" ? 1 : 0
  # ...
}
```

## Advanced Patterns

### Pattern 1: Multiple VMs with Different Sizes

```hcl
module "web_vm" {
  source = "./modules/vm"
  
  name_prefix = "web"
  vm_size     = "Standard_B2s"  # Smaller for web
  # ...
}

module "db_vm" {
  source = "./modules/vm"
  
  name_prefix = "db"
  vm_size     = "Standard_D4s_v3"  # Larger for database
  # ...
}
```

### Pattern 2: Environment-Based VM Sizes

```hcl
locals {
  vm_sizes = {
    "dev"  = "Standard_B1s"
    "prod" = "Standard_D2s_v3"
  }
}

module "vm" {
  source = "./modules/vm"
  
  vm_size = local.vm_sizes[var.environment]
  # ...
}
```

### Pattern 3: Using Module Outputs in Other Resources

```hcl
module "vm" {
  source = "./modules/vm"
  # ...
}

resource "azurerm_storage_account" "main" {
  name                = "mystorage"
  resource_group_name = module.vm.resource_group_name  # Use module output
  location            = module.vm.location
  # ...
}
```

## Troubleshooting

### Error: "Module not found"

**Solution:**
- Verify module paths: `./modules/vm` and `./modules/vm-alerts`
- Run `terraform init`

### Error: "VM size not valid"

**Solution:**
- Check VM size format: `Standard_B1s`, `Standard_D2s_v3`
- Verify size exists in your Azure region
- Use Azure CLI: `az vm list-sizes --location eastus`

### Error: "SSH key file not found"

**Solution:**
- Verify `ssh_public_key_path` points to existing file
- Generate key: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa`

### Alerts Not Created

**Solution:**
- Check `enable_alerts = true` in variables
- Verify VM module created successfully first
- Check alert module has access to VM outputs

### Email Notifications Not Working

**Solution:**
- Verify `alert_email` is set
- Check email address is valid
- Action group only created if email is provided

## Best Practices Demonstrated

1. ✅ **Separation of Concerns**: VM module for infrastructure, alerts module for monitoring
2. ✅ **Reusability**: Module can be used multiple times with different configurations
3. ✅ **Configurability**: VM sizes and alert thresholds are configurable
4. ✅ **Dependencies**: Proper module dependency management
5. ✅ **Outputs**: Expose necessary information via outputs
6. ✅ **Validation**: Validate VM sizes and thresholds
7. ✅ **Conditional Creation**: Alerts can be enabled/disabled

## Next Steps

- Add more alert types (disk, network)
- Create multiple VMs using for_each
- Add more VM configuration options (data disks, extensions)
- Create module dependencies (storage module uses VM module)
- Explore module versioning

## Summary

**Key Takeaways:**

1. **Modules** encapsulate related resources (VM + networking)
2. **Module outputs** connect modules together (VM → Alerts)
3. **Variables** make modules configurable (VM sizes, thresholds)
4. **Dependencies** are handled automatically by Terraform
5. **Conditional creation** allows flexible configurations
6. **Separation** keeps modules focused and reusable

This pattern demonstrates production-ready module design!

