# Task: Creating Terraform Modules - VM with Ansible Provisioning

This comprehensive guide walks you through converting the VM creation and Ansible provisioning code into a reusable Terraform module. You'll learn how modules work, how to structure them, and how to use them to create multiple VMs with different configurations.

## Learning Objectives

By completing this task, you will learn:
- What Terraform modules are and why to use them
- How to convert existing code into a module
- Module structure and best practices
- How to call modules from root configuration
- How to pass variables to modules
- How to use module outputs
- How to create multiple instances with different configurations
- How modules enable code reusability and maintainability
- How modules can depend on other modules
- How to create monitoring and alerting modules
- How to use module outputs as inputs to other modules

## Prerequisites

Before starting, ensure you have:
- Completed the "create_and_provision_with_ansible" task
- Understanding of Terraform resources and variables
- Azure subscription with appropriate permissions
- Terraform installed (version >= 1.9.0)
- Ansible installed (for provisioning)

---

## Part 1: Understanding Terraform Modules

### What is a Terraform Module?

A **Terraform module** is a container for multiple resources that are used together. Think of it as a reusable building block that encapsulates:

- **Resources**: The actual infrastructure components
- **Variables**: Inputs that customize the module's behavior
- **Outputs**: Values that other modules or the root module can use

### Why Use Modules?

1. **Reusability**: Write once, use many times
2. **Organization**: Group related resources together
3. **Abstraction**: Hide complexity behind a simple interface
4. **Maintainability**: Update in one place, changes propagate everywhere
5. **Testing**: Test modules independently
6. **Consistency**: Ensure resources are created the same way

### Module Structure

A Terraform module is simply a directory containing `.tf` files:

```
modules/
└── vm-with-ansible/
    ├── main.tf      # Resources and data sources
    ├── variables.tf  # Input variables
    ├── outputs.tf   # Output values
    └── ansible/     # Supporting files (playbooks, etc.)
        └── playbook.yml
```

**Key Point:** A module directory is just like a root Terraform configuration, but it's designed to be called by other configurations.

---

## Part 2: Project Structure

Let's examine the structure of this project:

```
creating_modules_in_terraform/
├── main.tf                    # Root module - calls child modules
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── provider.tf                # Provider configuration
├── terraform.tfvars.example   # Example variable values
├── task.md                    # This file
└── modules/                   # Child modules directory
    ├── vm-with-ansible/      # VM creation module
    │   ├── main.tf           # Module resources
    │   ├── variables.tf      # Module variables
    │   ├── outputs.tf        # Module outputs
    │   └── ansible/          # Ansible playbook
    │       └── playbook.yml
    └── alerts/               # VM monitoring module
        ├── main.tf           # Alert resources
        ├── variables.tf      # Alert variables
        ├── outputs.tf        # Alert outputs
        └── README.md         # Module documentation
```

### Understanding the Structure

- **Root Module** (main directory): The configuration that calls modules
- **Child Modules** (`modules/`): Reusable modules
  - `vm-with-ansible/`: Creates VM with Ansible provisioning
  - `alerts/`: Creates monitoring alerts for the VM
- **Module Source**: Path to the module directory
- **Module Dependencies**: Alerts module depends on VM module outputs

---

## Part 3: Converting Code to a Module

### Step 1: Understanding What Goes Into the Module

**What should be in the module:**
- VM creation logic
- Network resources (VNet, subnet, NSG)
- Public IP and network interface
- SSH key generation
- Ansible provisioning

**What stays in root:**
- Resource group (might be shared by multiple modules)
- Provider configuration
- High-level orchestration

### Step 2: Module Variables (Inputs)

Open `modules/vm-with-ansible/variables.tf`:

```hcl
variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g., 'web', 'app', 'db')"
}
```

**Key Points:**
- **Required variables**: No default value (must be provided)
- **Optional variables**: Have default values
- **Descriptions**: Document what each variable does
- **Types**: Define expected data types

**Why `name_prefix`?**
- Allows creating multiple VMs with different names
- Example: `web-vm-abc123`, `app-vm-xyz789`
- Prevents naming conflicts

### Step 3: Module Resources

Open `modules/vm-with-ansible/main.tf`:

**Key Changes from Original:**

1. **Resource Naming:**
   ```hcl
   # Original: "vm-${var.environment}-${random_id.suffix.hex}"
   # Module:   "${var.name_prefix}-vm-${random_id.suffix.hex}"
   ```
   Uses `name_prefix` instead of hardcoded "vm"

2. **Resource Group Reference:**
   ```hcl
   # Module receives resource_group_name as input
   resource_group_name = var.resource_group_name
   ```
   Module doesn't create resource group, uses existing one

3. **Path References:**
   ```hcl
   filename = "${path.module}/.ssh/id_rsa"
   ```
   `path.module` = module directory (not root directory)

**Understanding `path.module`:**
- In root: `path.module` = root directory
- In module: `path.module` = module directory
- Critical for file paths in modules

### Step 4: Module Outputs

Open `modules/vm-with-ansible/outputs.tf`:

```hcl
output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}
```

**Purpose:**
- Expose important values from the module
- Allow root module to use module outputs
- Enable module-to-module communication

---

## Part 4: Calling the Module

### Step 1: Understanding Module Calls

Open `main.tf` (root module):

```hcl
module "web_vm" {
  source = "./modules/vm-with-ansible"
  
  # Required variables
  name_prefix        = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  
  # ... other variables
}
```

**Breaking Down the Module Call:**

1. **`module "web_vm"`**: 
   - `module` = keyword for calling a module
   - `"web_vm"` = local name for this module instance
   - Used to reference outputs: `module.web_vm.vm_public_ip`

2. **`source = "./modules/vm-with-ansible"`**:
   - Path to module directory
   - Can be local path, Git URL, or registry

3. **Variable Assignment**:
   - Passes values from root to module
   - Can use root variables, resources, or literals

### Step 2: Passing Variables to Module

**Required Variables (no defaults):**
```hcl
name_prefix        = var.name_prefix
resource_group_name = azurerm_resource_group.main.name
location           = var.location
```

**Optional Variables (with defaults):**
```hcl
environment = var.environment  # Uses root variable
vm_size     = var.vm_size      # Can override module default
```

**Using Root Resources:**
```hcl
resource_group_name = azurerm_resource_group.main.name
```
- References resource created in root
- Module uses existing resource group

**Using Literals:**
```hcl
install_nginx = true
install_docker = false
```
- Direct values
- Not from variables

### Step 3: Using Module Outputs

Open `outputs.tf` (root):

```hcl
output "vm_public_ip" {
  value = module.web_vm.vm_public_ip
}
```

**Syntax:** `module.<module_name>.<output_name>`

**Why Re-export?**
- Root module can expose module outputs
- Or transform/combine outputs
- Provides clean interface to users

### Step 4: Module-to-Module Communication

**Using One Module's Outputs in Another Module:**

In this project, the alerts module uses outputs from the VM module:

```hcl
# VM module creates VM and outputs VM ID
module "web_vm" {
  source = "./modules/vm-with-ansible"
  # ...
}

# Alerts module uses VM module outputs
module "web_vm_alerts" {
  source = "./modules/alerts"
  
  vm_id   = module.web_vm.vm_id    # From VM module output
  vm_name = module.web_vm.vm_name  # From VM module output
  
  depends_on = [module.web_vm]      # Explicit dependency
}
```

**Key Points:**
- **Module Outputs**: `module.web_vm.vm_id` accesses VM module's output
- **Dependencies**: `depends_on` ensures VM is created before alerts
- **Data Flow**: VM module → outputs → Alerts module → inputs
- **Inheritance**: Alerts automatically inherit VM information

---

## Part 5: Step-by-Step Walkthrough

### Step 5.1: Review Module Structure

1. **Navigate to module directory:**
   ```bash
   cd modules/vm-with-ansible
   ls -la
   ```

2. **Examine module files:**
   - `main.tf` - All resources
   - `variables.tf` - Inputs
   - `outputs.tf` - Outputs
   - `ansible/playbook.yml` - Ansible playbook

3. **Key Differences from Root:**
   - Uses `var.resource_group_name` (doesn't create it)
   - Uses `var.name_prefix` for naming
   - Uses `path.module` for file paths

### Step 5.2: Review Root Module

1. **Navigate to root:**
   ```bash
   cd ../..
   ```

2. **Examine root files:**
   - `main.tf` - Calls the module
   - `variables.tf` - Root variables
   - `outputs.tf` - Re-exports module outputs

3. **Module Call:**
   ```hcl
   module "web_vm" {
     source = "./modules/vm-with-ansible"
     # ... variables
   }
   ```

### Step 5.3: Initialize Terraform

```bash
terraform init
```

**What Happens:**
- Downloads providers
- **Initializes modules** (downloads/copies module)
- Sets up backend

**Expected Output:**
```
Initializing modules...
- web_vm in modules/vm-with-ansible

Initializing provider plugins...
```

**Key Point:** Terraform treats modules as part of the configuration and initializes them.

### Step 5.4: Review the Plan

```bash
terraform plan
```

**What to Look For:**

1. **Module Resources:**
   ```
   # module.web_vm will be created
   + module.web_vm.azurerm_virtual_network.main
   + module.web_vm.azurerm_subnet.main
   + module.web_vm.azurerm_linux_virtual_machine.main
   ```

2. **Resource Naming:**
   - Notice `module.web_vm.` prefix
   - Shows resources belong to module

3. **Outputs:**
   ```
   Changes to Outputs:
     + vm_public_ip = (known after apply)
   ```

### Step 5.5: Apply the Configuration

```bash
terraform apply
```

**What Happens:**
1. Resource group created (root)
2. Module resources created:
   - VNet, subnet, NSG
   - Public IP, network interface
   - VM with Ansible provisioning
3. Outputs populated

**Time:** ~10-15 minutes (same as before)

### Step 5.6: Verify Module Outputs

```bash
terraform output
```

**Expected:**
```
vm_public_ip = "x.x.x.x"
vm_private_ip = "10.0.1.x"
ssh_command = "ssh -i ..."
```

**Access via Module:**
```bash
terraform output -raw ssh_command
```

---

## Part 6: Changing Module Variables

### Example 1: Change VM Size

Edit `terraform.tfvars`:
```hcl
vm_size = "Standard_B2s"  # Override environment default
```

**What Happens:**
- Module receives `vm_size = "Standard_B2s"`
- Ternary operator: `var.vm_size != ""` → true
- Uses provided size instead of environment default

**Apply:**
```bash
terraform plan  # See VM will be replaced
terraform apply
```

### Example 2: Change Name Prefix

Edit `terraform.tfvars`:
```hcl
name_prefix = "app"  # Changed from "web"
```

**What Happens:**
- All module resources get new names
- `app-vm-xxx`, `app-vnet-xxx`, etc.
- Creates new resources (old ones remain)

**Apply:**
```bash
terraform plan  # Shows new resources
terraform apply
```

### Example 3: Disable Ansible

Edit `terraform.tfvars`:
```hcl
enable_ansible = false
```

**What Happens:**
- Module receives `enable_ansible = false`
- Provisioner runs: `echo 'Ansible provisioning skipped'`
- VM created without Ansible

**Apply:**
```bash
terraform apply
# Notice: No Ansible output
```

### Example 4: Change Network Configuration

Edit `terraform.tfvars`:
```hcl
vnet_address_space      = ["172.16.0.0/16"]
subnet_address_prefixes = ["172.16.1.0/24"]
```

**What Happens:**
- Module receives new address spaces
- VNet and subnet use new ranges
- VM gets IP from new subnet

---

## Part 7: Creating Multiple VMs

### Step 7.1: Uncomment Second Module

Edit `main.tf` and uncomment the second module:

```hcl
module "app_vm" {
  source = "./modules/vm-with-ansible"

  name_prefix        = "app"
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  environment       = var.environment
  vm_size           = "Standard_B2s"  # Override default
  install_nginx     = false            # Don't install nginx
  install_docker    = true             # Install Docker instead

  tags = merge(var.tags, {
    Module = "app-vm"
  })
}
```

**Key Differences:**
- Different `name_prefix` → different resource names
- Different `vm_size` → larger VM
- Different Ansible config → Docker instead of nginx

### Step 7.2: Update Outputs

Add outputs for second VM:

```hcl
# App VM outputs
output "app_vm_public_ip" {
  value = module.app_vm.vm_public_ip
}

output "app_vm_ssh_command" {
  value = module.app_vm.ssh_command
}
```

### Step 7.3: Plan and Apply

```bash
terraform plan
```

**Expected:**
- Web VM resources (if not created)
- App VM resources (new)
- Two separate VMs with different configs

```bash
terraform apply
```

**Result:**
- Two VMs created
- Different configurations
- Same module, different parameters

---

## Part 8: Understanding Module Benefits

### Benefit 1: Code Reusability

**Without Module:**
- Copy-paste VM code for each VM
- 200+ lines × number of VMs
- Hard to maintain

**With Module:**
- Write module once
- Call module multiple times
- Change variables for different configs

### Benefit 2: Consistency

**All VMs Created the Same Way:**
- Same network configuration
- Same security settings
- Same provisioning process
- Ensures consistency

### Benefit 3: Maintainability

**Update Once, Apply Everywhere:**
1. Update module code
2. Run `terraform init -upgrade`
3. All VMs get updates

**Example:** Add HTTPS rule to NSG
- Update module NSG
- All VMs get HTTPS access

### Benefit 4: Abstraction

**Simple Interface:**
```hcl
module "web_vm" {
  source = "./modules/vm-with-ansible"
  name_prefix = "web"
  # ... few variables
}
```

**Complex Implementation Hidden:**
- VNet creation
- Subnet configuration
- NSG rules
- SSH keys
- Ansible provisioning
- All handled by module

---

## Part 9: Module Best Practices

### Practice 1: Clear Variable Names

**Good:**
```hcl
variable "name_prefix" { ... }
variable "resource_group_name" { ... }
```

**Bad:**
```hcl
variable "prefix" { ... }  # Unclear
variable "rg" { ... }      # Abbreviation
```

### Practice 2: Provide Defaults When Possible

**Good:**
```hcl
variable "environment" {
  default = "dev"
}
```

**Bad:**
```hcl
variable "environment" {
  # No default - always required
}
```

### Practice 3: Document Everything

**Good:**
```hcl
variable "vm_size" {
  type        = string
  description = "VM size. If empty, uses environment-based defaults."
  default     = ""
}
```

**Bad:**
```hcl
variable "vm_size" {
  type = string
}
```

### Practice 4: Expose Important Outputs

**Good:**
```hcl
output "vm_public_ip" { ... }
output "ssh_command" { ... }
```

**Bad:**
```hcl
# No outputs - can't use module values
```

### Practice 5: Use Consistent Naming

**Module Naming:**
- `vm-with-ansible` (kebab-case)
- Descriptive and clear

**Resource Naming:**
- Use `name_prefix` for uniqueness
- Include resource type in name

---

## Part 10: Advanced Module Concepts

### Concept 1: Module Dependencies

**Module can depend on root resources:**
```hcl
module "web_vm" {
  resource_group_name = azurerm_resource_group.main.name
  # Module waits for resource group
}
```

**Module can depend on other modules:**
```hcl
module "app_vm" {
  subnet_id = module.web_vm.subnet_id
  # Uses web_vm's subnet
}
```

### Concept 2: Conditional Module Creation

**Using count:**
```hcl
module "optional_vm" {
  count = var.create_vm ? 1 : 0
  source = "./modules/vm-with-ansible"
  # ...
}

# Reference with index
output "optional_vm_ip" {
  value = var.create_vm ? module.optional_vm[0].vm_public_ip : null
}
```

**Using for_each:**
```hcl
module "vms" {
  for_each = {
    web = { size = "Standard_B1s", install_nginx = true }
    app = { size = "Standard_B2s", install_docker = true }
  }
  
  source = "./modules/vm-with-ansible"
  name_prefix = each.key
  vm_size = each.value.size
  install_nginx = each.value.install_nginx
  install_docker = each.value.install_docker
}
```

### Concept 3: Module Versioning

**Local Path (current):**
```hcl
source = "./modules/vm-with-ansible"
```

**Git Source:**
```hcl
source = "git::https://github.com/org/repo.git//modules/vm?ref=v1.0.0"
```

**Terraform Registry:**
```hcl
source = "hashicorp/vm/azurerm"
version = "~> 1.0"
```

---

## Part 11: Troubleshooting Modules

### Issue: Module Not Found

**Error:** `Error: Module not found`

**Solutions:**
1. Check `source` path is correct
2. Verify module directory exists
3. Run `terraform init` to download modules

### Issue: Variable Not Set

**Error:** `Error: Missing required variable`

**Solutions:**
1. Check module's `variables.tf` for required variables
2. Provide value in module call
3. Or add default to module variable

### Issue: Output Not Available

**Error:** `Error: Reference to undeclared output`

**Solutions:**
1. Check output name matches exactly
2. Verify output exists in module's `outputs.tf`
3. Ensure module has been applied

### Issue: Path Issues

**Error:** File not found in module

**Solutions:**
1. Use `path.module` for module-relative paths
2. Check file exists in module directory
3. Verify path is correct

---

## Part 12: Verification Checklist

- [ ] Module directory structure created
- [ ] VM module `main.tf` contains all resources
- [ ] VM module `variables.tf` defines all inputs
- [ ] VM module `outputs.tf` exposes important values
- [ ] Alerts module created with monitoring resources
- [ ] Root `main.tf` calls both VM and Alerts modules
- [ ] Alerts module uses VM module outputs
- [ ] Variables passed correctly to modules
- [ ] `terraform init` succeeds
- [ ] `terraform plan` shows both module resources
- [ ] `terraform apply` creates resources successfully
- [ ] Module outputs accessible via `terraform output`
- [ ] Alerts configured in Azure Portal
- [ ] Can create multiple VMs with different configs
- [ ] Understand how modules work and depend on each other

---

## Questions for Reflection

Answer these questions to reinforce your learning:

### Question 1: Module Structure
**What are the three essential files in a Terraform module?**

**Answer:**
1. `main.tf` - Contains resources
2. `variables.tf` - Defines inputs
3. `outputs.tf` - Exposes outputs

### Question 2: Module Call Syntax
**How do you reference a module output in the root configuration?**

**Answer:**
```hcl
module.<module_name>.<output_name>
# Example: module.web_vm.vm_public_ip
```

### Question 3: Path References
**What's the difference between `path.root` and `path.module`?**

**Answer:**
- `path.root`: Root module directory (where you run terraform)
- `path.module`: Current module directory
- In modules, use `path.module` for module-relative paths

### Question 4: Variable Passing
**How do you pass a variable from root to module?**

**Answer:**
```hcl
module "example" {
  source = "./modules/example"
  variable_name = var.root_variable  # Pass root variable
  # or
  variable_name = "literal_value"    # Pass literal
}
```

### Question 5: Multiple Instances
**How do you create multiple VMs using the same module?**

**Answer:**
Call the module multiple times with different names:
```hcl
module "web_vm" { ... }
module "app_vm" { ... }
module "db_vm" { ... }
```

### Question 6: Module Benefits
**What are three main benefits of using modules?**

**Answer:**
1. **Reusability** - Write once, use many times
2. **Maintainability** - Update in one place
3. **Consistency** - Same pattern everywhere

### Question 7: Required vs Optional Variables
**How do you make a module variable optional?**

**Answer:**
Provide a default value:
```hcl
variable "optional_var" {
  type    = string
  default = "default_value"  # Makes it optional
}
```

### Question 8: Module Dependencies
**Can a module use resources created in the root module?**

**Answer:**
Yes, pass resource attributes as variables:
```hcl
module "vm" {
  resource_group_name = azurerm_resource_group.main.name
  # Uses root resource
}
```

### Question 9: Module Updates
**How do you update a module after making changes?**

**Answer:**
1. Update module code
2. Run `terraform init -upgrade` (if using Git/registry)
3. Run `terraform plan` to see changes
4. Run `terraform apply`

### Question 10: Module Scope
**What resources should be in a module vs. root?**

**Answer:**
- **Module**: Reusable components (VM, network for VM)
- **Root**: Shared resources (resource group), orchestration, provider config

### Question 11: Module Dependencies
**How does the alerts module get the VM ID?**

**Answer:**
The alerts module receives the VM ID from the VM module's output:
```hcl
module "web_vm_alerts" {
  vm_id = module.web_vm.vm_id  # Uses output from VM module
}
```
This creates a dependency: alerts module waits for VM module to complete.

### Question 12: Conditional Resource Creation
**How does `count = var.enable_alerts ? 1 : 0` work?**

**Answer:**
- If `enable_alerts` is true → `count = 1` → resource is created
- If `enable_alerts` is false → `count = 0` → resource is not created
- When using `count`, reference with index: `resource.name[0]`

### Question 13: Multiple Modules
**Can one module use outputs from another module?**

**Answer:**
Yes! This is called module composition:
```hcl
module "vm" { ... }
module "alerts" {
  vm_id = module.vm.vm_id  # Uses VM module output
}
```
This is how modules work together to build complex infrastructure.

---

## Part 13: Using Multiple Modules - VM Alerts Module

### Understanding Module Dependencies

In this project, we have **two modules**:
1. **vm-with-ansible**: Creates the VM and infrastructure
2. **alerts**: Monitors the VM for issues

The alerts module **depends on** the VM module because it needs the VM's ID and name to create alerts.

### Step 13.1: Understanding the Alerts Module

Open `modules/alerts/main.tf`:

**What the Alerts Module Creates:**

1. **Action Group** (`azurerm_monitor_action_group`):
   - Defines who receives alerts (email)
   - Only created if `enable_alerts = true` and email provided
   - Uses `count` for conditional creation

2. **Metric Alerts** (Performance Monitoring):
   - **CPU Alert**: Triggers when CPU > 80%
   - **Memory Alert**: Triggers when memory < threshold
   - **Disk Read/Write Alerts**: High disk activity
   - **Network Alert**: High inbound traffic

3. **Activity Log Alerts** (State Monitoring):
   - **VM Deallocation**: When VM is stopped
   - **VM Health**: Health status changes

### Step 13.2: Module-to-Module Communication

**In main.tf, see how modules connect:**

```hcl
# First module: Create VM
module "web_vm" {
  source = "./modules/vm-with-ansible"
  # ... variables
}

# Second module: Monitor the VM (depends on first module)
module "web_vm_alerts" {
  source = "./modules/alerts"
  
  # Use outputs from VM module
  vm_id   = module.web_vm.vm_id
  vm_name = module.web_vm.vm_name
  
  # Explicit dependency
  depends_on = [module.web_vm]
}
```

**Key Points:**
- **Module Outputs**: `module.web_vm.vm_id` accesses VM module output
- **Dependencies**: `depends_on` ensures VM is created first
- **Data Flow**: VM module → outputs → Alerts module → inputs

### Step 13.3: Understanding Alert Configuration

**Conditional Creation with Count:**

```hcl
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts && var.alert_email != "" ? 1 : 0
  # ...
}
```

**What this does:**
- Creates action group only if:
  - `enable_alerts` is true **AND**
  - `alert_email` is not empty
- Uses ternary operator: `condition ? 1 : 0`
- `count = 1` → create resource
- `count = 0` → don't create resource

**Referencing Conditional Resources:**

```hcl
action_group_id = var.alert_email != "" ? azurerm_monitor_action_group.main[0].id : null
```

- Uses index `[0]` because `count` creates a list
- Only references if resource exists
- Otherwise uses `null`

### Step 13.4: Alert Types Explained

#### Metric Alerts

**CPU Alert Example:**
```hcl
criteria {
  metric_namespace = "Microsoft.Compute/virtualMachines"
  metric_name      = "Percentage CPU"
  aggregation      = "Average"
  operator         = "GreaterThan"
  threshold        = 80
}
```

**What this monitors:**
- **Metric**: CPU percentage
- **Aggregation**: Average over time window
- **Operator**: Greater than threshold
- **Threshold**: 80% CPU usage
- **Action**: Send alert when exceeded

#### Activity Log Alerts

**VM Deallocation Alert:**
```hcl
criteria {
  operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
  category       = "Administrative"
}
```

**What this monitors:**
- **Operation**: VM deallocation action
- **Category**: Administrative operations
- **Action**: Alert when VM is stopped/deallocated

### Step 13.5: Testing the Alerts Module

1. **Configure Email:**
   Edit `terraform.tfvars`:
   ```hcl
   enable_alerts = true
   alert_email   = "your-email@example.com"
   ```

2. **Apply Configuration:**
   ```bash
   terraform apply
   ```

3. **Verify Alerts Created:**
   ```bash
   terraform output alert_count
   # Should show: 7
   ```

4. **Check Azure Portal:**
   - Go to Azure Portal → Monitor → Alerts
   - You should see 7 alerts configured
   - Check Action Groups for email configuration

### Step 13.6: Understanding Module Inheritance

**What "Inherited" Means:**

When we say alerts are "inherited" in main.tf, we mean:
- Alerts module automatically monitors the VM
- No need to manually configure each alert
- Changes to VM automatically reflected in alerts
- Single source of truth (VM module)

**Benefits:**
- **Automatic**: Alerts created automatically with VM
- **Consistent**: Same alerts for all VMs
- **Maintainable**: Update alerts module, all VMs get updates

### Step 13.7: Customizing Alerts

**Change Thresholds:**

Edit `terraform.tfvars`:
```hcl
cpu_threshold_percent = 90      # Higher threshold (less sensitive)
memory_threshold_percent = 75   # Lower threshold (more sensitive)
```

**Disable Alerts:**
```hcl
enable_alerts = false
```

**Change Alert Severity:**

The module uses environment to set severity:
- **Prod**: Severity 2 (higher priority)
- **Dev/Staging**: Severity 3 (lower priority)

### Step 13.8: Multiple VMs with Alerts

**Each VM Gets Its Own Alerts:**

```hcl
# Web VM with alerts
module "web_vm" { ... }
module "web_vm_alerts" {
  vm_id = module.web_vm.vm_id
  # ...
}

# App VM with alerts
module "app_vm" { ... }
module "app_vm_alerts" {
  vm_id = module.app_vm.vm_id
  # ...
}
```

**Result:**
- Each VM has independent alerts
- Can customize thresholds per VM
- Alerts isolated per VM

---

## Summary

In this task, you learned:

- ✅ **What modules are**: Reusable containers for Terraform resources
- ✅ **Module structure**: main.tf, variables.tf, outputs.tf
- ✅ **How to create modules**: Convert existing code into module format
- ✅ **How to call modules**: Use `module` block with `source`
- ✅ **Variable passing**: Pass values from root to module
- ✅ **Output usage**: Access module outputs via `module.name.output`
- ✅ **Multiple instances**: Call module multiple times with different configs
- ✅ **Module dependencies**: How modules can depend on other modules
- ✅ **Module composition**: Using one module's outputs in another module
- ✅ **Conditional resources**: Using `count` for optional resources
- ✅ **Best practices**: Naming, documentation, defaults
- ✅ **Benefits**: Reusability, maintainability, consistency

**Key Takeaway:** Modules transform Terraform from a scripting tool into a powerful infrastructure-as-code platform that promotes code reuse, consistency, and maintainability.

---

## Next Steps

1. **Experiment**: Create VMs with different configurations
2. **Extend**: Add more features to the module
3. **Refactor**: Break down into smaller modules
4. **Share**: Publish module to Git or registry
5. **Learn**: Explore Terraform Registry modules

---

## Additional Resources

- [Terraform Modules Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Module Composition](https://www.terraform.io/docs/language/modules/develop/composition.html)
- [Terraform Registry](https://registry.terraform.io/)

