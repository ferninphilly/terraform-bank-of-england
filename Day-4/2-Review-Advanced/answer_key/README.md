# Answer Key: Multi-Environment Network Infrastructure with for_each

This directory contains a complete Terraform configuration demonstrating `for_each` with variables for creating a multi-environment network infrastructure.

## Overview

This solution demonstrates:
- ✅ **for_each** with maps for creating multiple subnets
- ✅ **Dynamic blocks** with for_each for NSG rules
- ✅ **String manipulation** functions for naming
- ✅ **Complex variable structures** (map of objects)
- ✅ **Conditional resource creation** (NSG associations)
- ✅ **Multi-environment support**

## Files Overview

- `backend.tf` - Terraform backend configuration
- `provider.tf` - Azure provider configuration
- `variables.tf` - Variable definitions with validation
- `local.tf` - Locals for naming conventions and transformations
- `rg.tf` - Resource group
- `network.tf` - VNet, Subnets (for_each), NSG with dynamic rules
- `output.tf` - Comprehensive outputs
- `terraform.tfvars.example` - Example variable values

## Key Concepts Demonstrated

### 1. for_each with Subnets

**Variable Structure (Map of Objects):**
```hcl
variable "subnets" {
  type = map(object({
    address_prefix    = string
    service_endpoints = list(string)
    nsg_enabled       = bool
  }))
}
```

**Resource Creation:**
```hcl
resource "azurerm_subnet" "main" {
  for_each = var.subnets
  
  name                 = local.subnet_names[each.key]
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints
}
```

**Key Points:**
- `each.key` = subnet name ("frontend", "backend", "database")
- `each.value` = object with configuration
- `each.value.address_prefix` = access object properties

### 2. Dynamic Blocks with for_each

**Variable Structure:**
```hcl
variable "nsg_rules" {
  type = map(object({
    priority              = number
    direction             = string
    # ... more properties
  }))
}
```

**Dynamic Block:**
```hcl
dynamic "security_rule" {
  for_each = var.nsg_rules
  
  content {
    name     = security_rule.key
    priority = security_rule.value.priority
    # ...
  }
}
```

**Key Points:**
- `security_rule.key` = rule name ("AllowSSH", "AllowHTTP")
- `security_rule.value` = rule configuration object
- Creates one rule per map item

### 3. Conditional Resource Creation

**Filtering Map:**
```hcl
locals {
  subnets_with_nsg = {
    for k, v in var.subnets : k => v
    if v.nsg_enabled == true
  }
}
```

**Conditional Association:**
```hcl
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = local.subnets_with_nsg
  
  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main.id
}
```

**Key Points:**
- Only creates associations for subnets where `nsg_enabled = true`
- Uses filtered map in for_each

### 4. String Manipulation

**Naming Convention:**
```hcl
locals {
  normalized_project_name = lower(replace(var.project_name, " ", "-"))
  name_prefix            = "${local.normalized_project_name}-${var.environment}"
  
  subnet_names = {
    for k, v in var.subnets : k => "${local.name_prefix}-${k}-subnet"
  }
}
```

**Functions Used:**
- `lower()` - Convert to lowercase
- `replace()` - Replace characters
- String interpolation - Combine values

## Usage

### 1. Copy Example Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Customize Variables

Edit `terraform.tfvars`:
- Update `environment` (dev/staging/prod)
- Update `project_name`
- Modify `subnets` map to add/remove subnets
- Customize `nsg_rules` map

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan
```

**Expected Output:**
- 1 Resource Group
- 1 Virtual Network
- 3 Subnets (frontend, backend, database)
- 1 Network Security Group
- 3 NSG Rules (SSH, HTTP, HTTPS)
- 2 NSG Associations (frontend, backend - database doesn't have NSG)

### 5. Apply Configuration

```bash
terraform apply
```

### 6. View Outputs

```bash
terraform output
```

## Adding More Subnets

To add more subnets, simply add to the `subnets` map in `terraform.tfvars`:

```hcl
subnets = {
  "frontend" = { ... }
  "backend" = { ... }
  "database" = { ... }
  "new-subnet" = {
    address_prefix    = "10.0.4.0/24"
    service_endpoints = ["Microsoft.KeyVault"]
    nsg_enabled       = true
  }
}
```

Terraform will automatically create the new subnet using `for_each`!

## Adding More NSG Rules

To add more NSG rules, add to the `nsg_rules` map:

```hcl
nsg_rules = {
  "AllowSSH" = { ... }
  "AllowHTTP" = { ... }
  "AllowHTTPS" = { ... }
  "AllowRDP" = {
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow RDP from internet"
  }
}
```

The dynamic block will automatically create the new rule!

## Understanding the for_each Patterns

### Pattern 1: Simple Map Iteration

```hcl
for_each = var.subnets
# Creates: azurerm_subnet.main["frontend"], azurerm_subnet.main["backend"], etc.
```

### Pattern 2: Filtered Map

```hcl
for_each = {
  for k, v in var.subnets : k => v
  if v.nsg_enabled == true
}
# Only includes subnets where nsg_enabled = true
```

### Pattern 3: Transformed Map

```hcl
locals {
  subnet_names = {
    for k, v in var.subnets : k => "${local.name_prefix}-${k}-subnet"
  }
}
# Transforms keys into formatted names
```

## Resource References

### Reference a Specific Subnet

```hcl
# In another resource
subnet_id = azurerm_subnet.main["frontend"].id
```

### Reference All Subnets

```hcl
# In outputs
output "all_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.main : k => v.id
  }
}
```

### Reference Subnets Conditionally

```hcl
# Only subnets with NSG
output "subnets_with_nsg" {
  value = {
    for k, v in azurerm_subnet.main : k => v.id
    if var.subnets[k].nsg_enabled == true
  }
}
```

## Best Practices Demonstrated

1. ✅ **Meaningful Keys**: Subnet keys are descriptive ("frontend", "backend")
2. ✅ **Type Validation**: All variables have type constraints and validation
3. ✅ **String Functions**: Used for consistent naming
4. ✅ **Locals for Transformations**: Complex logic in locals, not inline
5. ✅ **Documentation**: All variables have descriptions
6. ✅ **Sensible Defaults**: Variables have default values
7. ✅ **Conditional Logic**: Filtered maps for conditional resources

## Troubleshooting

### Error: "for_each value must be a map"

**Problem:** Variable is a list, not a map.

**Solution:** Convert to map:
```hcl
locals {
  subnets_map = {
    for idx, name in var.subnet_list : name => {
      address_prefix = "10.0.${idx + 1}.0/24"
    }
  }
}
```

### Error: "Invalid index"

**Problem:** Referencing a key that doesn't exist.

**Solution:** Check the key exists:
```hcl
# Check available keys
output "available_subnets" {
  value = keys(var.subnets)
}
```

### Subnet Not Created

**Problem:** Subnet missing from `var.subnets` map.

**Solution:** Add to the map in `terraform.tfvars`.

## Next Steps

- Add more subnet types (DMZ, management, etc.)
- Create VMs in different subnets using for_each
- Add more NSG rules for different protocols
- Implement subnet delegation
- Add route tables with for_each

## Additional Resources

- See `../for_each_and_variables_review.md` for detailed explanations
- [Terraform for_each Documentation](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Terraform Dynamic Blocks](https://www.terraform.io/docs/language/expressions/dynamic-blocks.html)

