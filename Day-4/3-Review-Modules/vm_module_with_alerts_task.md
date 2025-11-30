# Task: Creating a VM Module with Alerts

This task focuses on creating a comprehensive Virtual Machine module with monitoring alerts and configurable VM sizes.

## Learning Objectives

By the end of this task, you will:
- Create a complete VM module with networking components
- Pass configurable VM sizes via variables
- Integrate monitoring alerts with the VM module
- Understand module dependencies (alerts module depends on VM module)
- Use module outputs to connect modules together

## Task Overview

Create a reusable **Virtual Machine module** that includes:
- Complete networking (VNet, Subnet, Public IP, NSG, NIC)
- Configurable VM with different sizes
- Monitoring alerts (CPU and Memory)
- Proper variable passing and outputs

### Module Structure

```
modules/
├── vm/
│   ├── main.tf          # VM and networking resources
│   ├── variables.tf     # VM module variables
│   └── outputs.tf       # VM module outputs
└── vm-alerts/
    ├── main.tf          # Alert resources
    ├── variables.tf     # Alert module variables
    └── outputs.tf       # Alert module outputs
```

### Root Module Structure

```
.
├── main.tf              # Uses VM module and alerts module
├── variables.tf          # Root module variables
├── outputs.tf           # Root module outputs
├── provider.tf
├── backend.tf
└── modules/
    ├── vm/
    └── vm-alerts/
```

## Step-by-Step Instructions

### Step 1: Create VM Module Directory

```bash
mkdir -p modules/vm
touch modules/vm/main.tf
touch modules/vm/variables.tf
touch modules/vm/outputs.tf
```

### Step 2: Define VM Module Variables

**File: `modules/vm/variables.tf`**

```hcl
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine (e.g., Standard_B1s, Standard_B2s)"
  type        = string
  default     = "Standard_B1s"
  
  validation {
    condition = can(regex("^Standard_[A-Z][0-9]+[a-z]*$", var.vm_size))
    error_message = "VM size must be a valid Azure VM size."
  }
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

**Key Points:**
- `vm_size` is configurable with validation
- Networking configuration is included
- All values can be passed from root module

### Step 3: Create VM Module Resources

**File: `modules/vm/main.tf`**

Create all networking and VM resources (reuse from previous exercises):
- Virtual Network
- Subnet
- Public IP
- Network Security Group
- Network Interface
- Linux Virtual Machine

### Step 4: Create VM Module Outputs

**File: `modules/vm/outputs.tf`**

Expose information needed by alerts module:

```hcl
output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name
}

output "location" {
  description = "Location"
  value       = var.location
}
```

### Step 5: Create Alerts Module

**File: `modules/vm-alerts/variables.tf`**

```hcl
variable "vm_id" {
  description = "ID of the VM to monitor"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for alert names"
  type        = string
}

variable "enable_alerts" {
  description = "Whether to enable alerts"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = ""
}

variable "cpu_threshold_percent" {
  description = "CPU usage threshold percentage"
  type        = number
  default     = 80
}

variable "memory_threshold_percent" {
  description = "Memory usage threshold percentage"
  type        = number
  default     = 85
}
```

**File: `modules/vm-alerts/main.tf`**

Create:
- Action Group (for email notifications)
- CPU Alert
- Memory Alert

### Step 6: Use Modules in Root Module

**File: `main.tf`**

```hcl
# Use VM module
module "vm" {
  source = "./modules/vm"
  
  name_prefix        = var.name_prefix
  resource_group_name = var.resource_group_name
  location           = var.location
  vm_size           = var.vm_size  # Configurable!
  admin_username    = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  tags              = var.tags
}

# Use alerts module (depends on VM module)
module "vm_alerts" {
  source = "./modules/vm-alerts"
  
  vm_id              = module.vm.vm_id
  vm_name            = module.vm.vm_name
  resource_group_name = module.vm.resource_group_name
  location           = module.vm.location
  name_prefix        = var.name_prefix
  enable_alerts      = var.enable_alerts
  alert_email        = var.alert_email
  cpu_threshold_percent = var.cpu_threshold_percent
  memory_threshold_percent = var.memory_threshold_percent
}
```

**Key Points:**
- VM module creates the VM
- Alerts module uses VM module outputs
- VM size is passed as a variable

## Understanding Module Dependencies

```
Root Module
    ↓
VM Module (creates VM)
    ↓ (outputs: vm_id, vm_name)
Alerts Module (uses VM outputs)
```

**Dependency Flow:**
1. Root module calls VM module
2. VM module creates VM and outputs VM ID/name
3. Root module passes VM outputs to alerts module
4. Alerts module creates alerts for the VM

## Variable Passing Flow

```
Root Variables (variables.tf)
    ↓
VM Module (main.tf module block)
    ↓
VM Module Variables (modules/vm/variables.tf)
    ↓
VM Resources (modules/vm/main.tf)
    ↓
VM Module Outputs (modules/vm/outputs.tf)
    ↓
Root Module (main.tf - alerts module block)
    ↓
Alerts Module Variables (modules/vm-alerts/variables.tf)
    ↓
Alert Resources (modules/vm-alerts/main.tf)
```

## Key Concepts

### 1. Configurable VM Sizes

```hcl
# In root variables.tf
variable "vm_size" {
  type    = string
  default = "Standard_B1s"  # Can be changed!
}

# Pass to module
module "vm" {
  vm_size = var.vm_size  # Passes to module
}
```

### 2. Module Dependencies

```hcl
# VM module must be created first
module "vm" {
  # ...
}

# Alerts module uses VM outputs
module "vm_alerts" {
  vm_id = module.vm.vm_id  # Depends on VM module
}
```

### 3. Conditional Alerts

```hcl
variable "enable_alerts" {
  type    = bool
  default = true
}

module "vm_alerts" {
  source = "./modules/vm-alerts"
  count  = var.enable_alerts ? 1 : 0  # Conditional creation
  # ...
}
```

## Best Practices

1. ✅ **Separate concerns**: VM module for infrastructure, alerts module for monitoring
2. ✅ **Use outputs**: Connect modules via outputs, not direct resource references
3. ✅ **Validate inputs**: Validate VM sizes and other critical inputs
4. ✅ **Document variables**: Always include descriptions
5. ✅ **Provide defaults**: Sensible defaults for optional values
6. ✅ **Handle dependencies**: Ensure correct order (VM before alerts)

## Deliverables

- ✅ Complete VM module with networking
- ✅ Alerts module with CPU and Memory alerts
- ✅ Root module using both modules
- ✅ Configurable VM sizes via variables
- ✅ Proper module outputs and dependencies

## Next Steps

After completing this task:
- Add more alert types (disk, network)
- Create multiple VM instances using for_each
- Add more VM configuration options
- Explore module versioning

