# Complete Review: for_each and Variables in Terraform

This comprehensive guide covers how `for_each` works with variables to create multiple resources dynamically in Terraform.

## Table of Contents
1. [Understanding for_each](#understanding-for_each)
2. [Variable Types for for_each](#variable-types-for-for_each)
3. [Basic for_each with Maps](#basic-for_each-with-maps)
4. [for_each with Complex Variable Structures](#for_each-with-complex-variable-structures)
5. [for_each vs count](#for_each-vs-count)
6. [Advanced Patterns](#advanced-patterns)
7. [Common Use Cases](#common-use-cases)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Understanding for_each

### What is for_each?

`for_each` is a Terraform meta-argument that allows you to create multiple instances of a resource based on a **map** or **set** of values. Think of it as a loop that creates one resource for each item in your collection.

**Key Concepts:**
- **Iterates over**: Maps or sets (not lists directly)
- **Creates**: One resource instance per item
- **Access**: Use `each.key` and `each.value` to reference current item
- **Benefits**: Named resources, easy to add/remove items, stable resource addresses

### Why Use for_each?

**Before for_each (Manual):**
```hcl
resource "azurerm_storage_account" "storage1" {
  name = "mystorage1"
  # ...
}

resource "azurerm_storage_account" "storage2" {
  name = "mystorage2"
  # ...
}

resource "azurerm_storage_account" "storage3" {
  name = "mystorage3"
  # ...
}
```

**With for_each (Dynamic):**
```hcl
resource "azurerm_storage_account" "storage" {
  for_each = var.storage_accounts
  
  name = each.key
  # ...
}
```

**Benefits:**
- ✅ **DRY Principle**: Write once, create many
- ✅ **Easy to Scale**: Add items to variable, Terraform handles the rest
- ✅ **Stable Addresses**: Resources identified by key, not position
- ✅ **Easy Removal**: Remove from map, Terraform knows exactly what to delete
- ✅ **Named Resources**: Each resource has a meaningful name (the key)

---

## Variable Types for for_each

`for_each` works with two types of collections:

### 1. Maps

A **map** is a collection of key-value pairs. Each key must be unique.

**Syntax:**
```hcl
variable "example_map" {
  type = map(string)
  default = {
    "key1" = "value1"
    "key2" = "value2"
    "key3" = "value3"
  }
}
```

**In for_each:**
- `each.key` = the map key (e.g., "key1")
- `each.value` = the map value (e.g., "value1")

**Example:**
```hcl
variable "environments" {
  type = map(string)
  default = {
    "dev"  = "eastus"
    "prod" = "westus2"
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  
  name     = "myapp-${each.key}-rg"
  location = each.value  # "eastus" or "westus2"
}
```

### 2. Sets

A **set** is a collection of unique values (no keys, just values).

**Syntax:**
```hcl
variable "example_set" {
  type = set(string)
  default = ["value1", "value2", "value3"]
}
```

**In for_each:**
- `each.key` = the value itself (same as `each.value`)
- `each.value` = the value itself

**Example:**
```hcl
variable "subnet_names" {
  type = set(string)
  default = ["frontend", "backend", "database"]
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_names
  
  name                 = each.value  # "frontend", "backend", or "database"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.${index(var.subnet_names, each.value)}.0/24"]
}
```

**Note:** Sets are less common than maps because maps give you more control with named keys.

---

## Basic for_each with Maps

### Simple Map Example

**Step 1: Define the Variable**

```hcl
# variables.tf
variable "storage_accounts" {
  description = "Map of storage accounts to create"
  type = map(string)
  default = {
    "app-data"  = "Standard_LRS"
    "backup"    = "Standard_GRS"
    "archive"   = "Standard_ZRS"
  }
}
```

**Step 2: Use for_each in Resource**

```hcl
# storage.tf
resource "azurerm_storage_account" "main" {
  for_each = var.storage_accounts
  
  name                     = "${var.name_prefix}-${each.key}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = each.value  # "Standard_LRS", "Standard_GRS", or "Standard_ZRS"
  
  tags = {
    Name = each.key
  }
}
```

**Step 3: Reference the Resources**

```hcl
# output.tf
output "storage_account_names" {
  value = {
    for k, v in azurerm_storage_account.main : k => v.name
  }
}

output "storage_account_ids" {
  value = {
    for k, v in azurerm_storage_account.main : k => v.id
  }
}

# Reference a specific storage account
output "app_data_storage_id" {
  value = azurerm_storage_account.main["app-data"].id
}
```

**What Happens:**
- Terraform creates 3 storage accounts:
  - `myprefix-app-data` (Standard_LRS)
  - `myprefix-backup` (Standard_GRS)
  - `myprefix-archive` (Standard_ZRS)
- Each resource is identified by its key: `azurerm_storage_account.main["app-data"]`

---

## for_each with Complex Variable Structures

### Map of Objects

When you need multiple properties per resource, use a **map of objects**.

**Step 1: Define Complex Variable**

```hcl
# variables.tf
variable "virtual_machines" {
  description = "Map of virtual machines to create"
  type = map(object({
    vm_size        = string
    admin_username = string
    subnet_name    = string
    tags           = map(string)
  }))
  
  default = {
    "web-server-1" = {
      vm_size        = "Standard_B2s"
      admin_username = "admin"
      subnet_name    = "frontend"
      tags = {
        Role = "WebServer"
        Tier = "Frontend"
      }
    }
    "app-server-1" = {
      vm_size        = "Standard_D2s_v3"
      admin_username = "admin"
      subnet_name    = "backend"
      tags = {
        Role = "AppServer"
        Tier = "Backend"
      }
    }
    "db-server-1" = {
      vm_size        = "Standard_D4s_v3"
      admin_username = "admin"
      subnet_name    = "database"
      tags = {
        Role = "Database"
        Tier = "Data"
      }
    }
  }
}
```

**Step 2: Use in Resource**

```hcl
# vm.tf
resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.virtual_machines
  
  name                  = each.key  # "web-server-1", "app-server-1", etc.
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = each.value.vm_size  # Access object property
  admin_username        = each.value.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.main[each.value.subnet_name].id
  ]
  
  # Access nested object properties
  tags = each.value.tags
  
  # OS Disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  # Source Image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
```

**Step 3: Reference Specific VM**

```hcl
# output.tf
output "web_server_private_ip" {
  value = azurerm_network_interface.main["frontend"].private_ip_address
}

output "all_vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.main : vm.name]
}

output "vm_details" {
  value = {
    for k, v in azurerm_linux_virtual_machine.main : k => {
      name       = v.name
      private_ip = azurerm_network_interface.main[var.virtual_machines[k].subnet_name].private_ip_address
      size       = v.size
    }
  }
}
```

### Nested Maps

For even more complex structures, you can nest maps:

```hcl
# variables.tf
variable "environments" {
  type = map(map(object({
    vm_size = string
    count   = number
  })))
  
  default = {
    "dev" = {
      "web" = {
        vm_size = "Standard_B1s"
        count   = 1
      }
      "app" = {
        vm_size = "Standard_B1s"
        count   = 1
      }
    }
    "prod" = {
      "web" = {
        vm_size = "Standard_D2s_v3"
        count   = 3
      }
      "app" = {
        vm_size = "Standard_D4s_v3"
        count   = 2
      }
    }
  }
}
```

**Usage:**
```hcl
resource "azurerm_linux_virtual_machine" "main" {
  for_each = {
    for env_key, env_value in var.environments : 
    "${env_key}-${tier_key}" => {
      env_key  = env_key
      tier_key = tier_key
      config   = tier_value
    }
    for tier_key, tier_value in env_value
  }
  
  name = "${each.value.env_key}-${each.value.tier_key}-vm"
  size = each.value.config.vm_size
  # ...
}
```

---

## for_each vs count

### When to Use for_each

✅ **Use for_each when:**
- You have a **map** or **set** of items
- Resources need **meaningful names** (keys)
- You want to **add/remove items** without affecting others
- You need to **reference resources by name** (not index)

**Example:**
```hcl
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets
  
  name                 = each.key  # "frontend", "backend"
  address_prefixes     = [each.value.address_prefix]
}
```

### When to Use count

✅ **Use count when:**
- You have a **simple number** (0, 1, 2, 3...)
- Resources don't need meaningful names
- You want **simple on/off** conditional creation
- Order matters (though this is often a limitation)

**Example:**
```hcl
variable "create_nat_gateway" {
  type    = bool
  default = true
}

resource "azurerm_nat_gateway" "main" {
  count = var.create_nat_gateway ? 1 : 0
  
  name = "nat-gateway"
  # ...
}
```

### Comparison Table

| Feature | for_each | count |
|---------|----------|-------|
| **Input Type** | Map or Set | Number |
| **Resource Address** | `resource.name["key"]` | `resource.name[0]` |
| **Adding Items** | Add to map, stable | Can affect other resources |
| **Removing Items** | Remove from map, stable | Can affect other resources |
| **Named Resources** | Yes (keys) | No (indices) |
| **Best For** | Dynamic collections | Simple conditionals/fixed counts |

### Converting Lists to Maps for for_each

If you have a list but want to use for_each, convert it:

```hcl
variable "subnet_names" {
  type    = list(string)
  default = ["frontend", "backend", "database"]
}

# Convert list to map
locals {
  subnet_map = {
    for idx, name in var.subnet_names : name => {
      address_prefix = "10.0.${idx + 1}.0/24"
    }
  }
}

resource "azurerm_subnet" "main" {
  for_each = local.subnet_map
  
  name                 = each.key
  address_prefixes     = [each.value.address_prefix]
}
```

---

## Advanced Patterns

### 1. Conditional for_each

Create resources conditionally:

```hcl
variable "create_storage_accounts" {
  type    = bool
  default = true
}

variable "storage_accounts" {
  type = map(object({
    replication_type = string
  }))
  default = {}
}

resource "azurerm_storage_account" "main" {
  for_each = var.create_storage_accounts ? var.storage_accounts : {}
  
  name                = each.key
  # ...
}
```

### 2. Filtering Maps

Only create resources that meet certain conditions:

```hcl
variable "environments" {
  type = map(object({
    enabled = bool
    region  = string
  }))
}

resource "azurerm_resource_group" "rg" {
  for_each = {
    for k, v in var.environments : k => v
    if v.enabled == true
  }
  
  name     = "${k}-rg"
  location = each.value.region
}
```

### 3. Transforming Maps

Transform data before using in for_each:

```hcl
variable "vm_configs" {
  type = map(object({
    size = string
  }))
}

locals {
  # Add computed values
  vm_configs_enhanced = {
    for k, v in var.vm_configs : k => {
      size        = v.size
      name        = "${var.prefix}-${k}"
      tags        = merge(var.common_tags, { Name = k })
      disk_size   = v.size == "Standard_B1s" ? 30 : 50
    }
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = local.vm_configs_enhanced
  
  name = each.value.name
  size = each.value.size
  tags = each.value.tags
  # ...
}
```

### 4. Combining Multiple Maps

Merge multiple maps:

```hcl
variable "common_tags" {
  type    = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "vm_specific_tags" {
  type = map(map(string))
  default = {
    "web-server" = {
      Role = "WebServer"
    }
    "app-server" = {
      Role = "AppServer"
    }
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.vm_specific_tags
  
  name = each.key
  tags = merge(
    var.common_tags,
    each.value
  )
  # ...
}
```

### 5. Dynamic Blocks with for_each

#### What is a Dynamic Block?

A **dynamic block** is a special Terraform construct that allows you to create **nested blocks** (like `security_rule`, `ip_configuration`, `tag`) dynamically based on a collection. Think of it as `for_each` for blocks that are **inside** a resource, not for creating multiple resources.

**Key Concepts:**
- **Purpose**: Create multiple nested blocks within a single resource
- **Use Case**: When a resource has a block that can repeat (like NSG rules, tags, IP configurations)
- **Works With**: Maps, sets, and lists
- **Syntax**: `dynamic "block_name" { for_each = ... content { ... } }`

#### Why Dynamic Blocks?

**Problem:** Some Azure resources have blocks that can repeat, but you can't use `for_each` on the resource itself because you only want **one** resource with **multiple** nested blocks.

**Example - Network Security Group:**
- You want **one** NSG resource
- But you need **multiple** `security_rule` blocks inside it
- Each rule has different configuration

**Without Dynamic Blocks (Manual):**
```hcl
resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  # Hard-coded rules - not flexible!
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    # ... more properties
  }
  
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    # ... more properties
  }
  
  # What if you need 10 rules? 20 rules? This becomes unmanageable!
}
```

**With Dynamic Blocks (Flexible):**
```hcl
resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  # Dynamic block creates multiple security_rule blocks
  dynamic "security_rule" {
    for_each = var.nsg_rules  # Map of rules
    
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      # ... uses values from map
    }
  }
}
```

#### How Dynamic Blocks Work

**Syntax Structure:**
```hcl
dynamic "block_name" {
  for_each = collection  # Map, set, or list
  
  content {
    # Properties of the nested block
    # Use each.key and each.value to access collection items
  }
}
```

**Step-by-Step Explanation:**

1. **`dynamic "block_name"`**: The name must match the nested block type in the resource (e.g., `"security_rule"`, `"ip_configuration"`, `"tag"`)

2. **`for_each = collection`**: The collection to iterate over (map, set, or list)

3. **`content { }`**: Defines what goes inside each nested block

4. **Accessing Values**: Inside `content`, use `each.key` and `each.value` (or the block name if iterating over a map)

**Important:** The iteration variable name inside a dynamic block is `each`, not the block name!

#### Complete Example: NSG with Dynamic Rules

**Step 1: Define Variable (Map of Objects)**

```hcl
variable "nsg_rules" {
  description = "Map of Network Security Group rules"
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = string
  }))
  
  default = {
    "AllowSSH" = {
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH from anywhere"
    }
    "AllowHTTP" = {
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP from internet"
    }
    "AllowHTTPS" = {
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from internet"
    }
  }
}
```

**Step 2: Use Dynamic Block in Resource**

```hcl
resource "azurerm_network_security_group" "main" {
  name                = "example-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Dynamic block: creates multiple security_rule blocks
  dynamic "security_rule" {
    for_each = var.nsg_rules  # Iterates over the map
    
    content {
      # Each property uses values from the map
      name                       = security_rule.key        # "AllowSSH", "AllowHTTP", etc.
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  
  tags = {
    Environment = "dev"
  }
}
```

**What Happens:**
- Terraform creates **one** NSG resource
- Inside that NSG, it creates **three** `security_rule` blocks (one for each item in the map)
- Each rule uses the configuration from `var.nsg_rules`

**Equivalent Manual Code:**
```hcl
resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  security_rule {
    name = "AllowSSH"
    priority = 1001
    # ... (from var.nsg_rules["AllowSSH"])
  }
  
  security_rule {
    name = "AllowHTTP"
    priority = 1002
    # ... (from var.nsg_rules["AllowHTTP"])
  }
  
  security_rule {
    name = "AllowHTTPS"
    priority = 1003
    # ... (from var.nsg_rules["AllowHTTPS"])
  }
}
```

#### Dynamic Blocks vs Regular for_each

**Key Difference:**

| Feature | Regular for_each | Dynamic Block |
|---------|------------------|---------------|
| **Creates** | Multiple resources | Multiple nested blocks |
| **Resource Count** | N resources (one per item) | 1 resource |
| **Use Case** | Multiple subnets, VMs, storage accounts | Multiple rules, tags, IP configs |
| **Example** | `resource "azurerm_subnet" { for_each = ... }` | `dynamic "security_rule" { for_each = ... }` |

**When to Use Each:**

✅ **Use Regular for_each** when:
- You want multiple **resources** (e.g., multiple subnets, multiple VMs)
- Each item should be a separate resource

✅ **Use Dynamic Blocks** when:
- You want **one resource** with multiple **nested blocks** (e.g., one NSG with multiple rules)
- The resource supports repeating blocks

#### More Dynamic Block Examples

**Example 1: Multiple IP Configurations (NIC)**

```hcl
variable "ip_configurations" {
  type = map(object({
    name                          = string
    subnet_id                     = string
    private_ip_address_allocation = string
    public_ip_id                  = string
  }))
  
  default = {
    "primary" = {
      name                          = "primary-ip"
      subnet_id                     = azurerm_subnet.main.id
      private_ip_address_allocation = "Dynamic"
      public_ip_id                  = azurerm_public_ip.main.id
    }
    "secondary" = {
      name                          = "secondary-ip"
      subnet_id                     = azurerm_subnet.main.id
      private_ip_address_allocation = "Static"
      public_ip_id                  = null
    }
  }
}

resource "azurerm_network_interface" "main" {
  name = "example-nic"
  
  # Dynamic block for multiple IP configurations
  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    
    content {
      name                          = ip_configuration.value.name
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      public_ip_address_id          = ip_configuration.value.public_ip_id
    }
  }
}
```

**Example 2: Multiple Tags (if resource supports tag blocks)**

```hcl
variable "resource_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "MyProject"
    Owner       = "DevOps"
  }
}

resource "azurerm_resource_group" "main" {
  name = "example-rg"
  
  # Note: Most Azure resources use tags as a map, not dynamic blocks
  # This is just an example if a resource supported tag blocks
  tags = var.resource_tags  # Usually just assign the map directly
}
```

**Example 3: Conditional Dynamic Blocks**

```hcl
variable "create_custom_rules" {
  type    = bool
  default = true
}

variable "custom_nsg_rules" {
  type = map(object({
    priority = number
    # ... other properties
  }))
  default = {}
}

resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  # Always create default rules
  dynamic "security_rule" {
    for_each = {
      "AllowSSH" = {
        priority = 1001
        # ... default SSH rule
      }
    }
    content { /* ... */ }
  }
  
  # Conditionally create custom rules
  dynamic "security_rule" {
    for_each = var.create_custom_rules ? var.custom_nsg_rules : {}
    
    content {
      name     = security_rule.key
      priority = security_rule.value.priority
      # ... other properties
    }
  }
}
```

#### Common Patterns

**Pattern 1: Filtering in Dynamic Blocks**

```hcl
variable "all_rules" {
  type = map(object({
    enabled = bool
    priority = number
    # ...
  }))
}

resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  dynamic "security_rule" {
    # Only create rules where enabled = true
    for_each = {
      for k, v in var.all_rules : k => v
      if v.enabled == true
    }
    
    content {
      name     = security_rule.key
      priority = security_rule.value.priority
      # ...
    }
  }
}
```

**Pattern 2: Transforming Data for Dynamic Blocks**

```hcl
variable "rule_configs" {
  type = map(object({
    port    = number
    enabled = bool
  }))
}

locals {
  # Transform to NSG rule format
  nsg_rules = {
    for k, v in var.rule_configs : k => {
      priority              = 1000 + v.port
      destination_port_range = tostring(v.port)
      # ... other computed values
    }
    if v.enabled == true
  }
}

resource "azurerm_network_security_group" "main" {
  name = "example-nsg"
  
  dynamic "security_rule" {
    for_each = local.nsg_rules
    
    content {
      name                   = security_rule.key
      priority               = security_rule.value.priority
      destination_port_range = security_rule.value.destination_port_range
      # ...
    }
  }
}
```

#### Important Notes

1. **Variable Naming**: Inside `content`, use `each.key` and `each.value` (or the block name if iterating over a map). The block name (`security_rule`) is used as a prefix when iterating over maps.

2. **Empty Collections**: If `for_each` is an empty map/set/list, no blocks are created (no error).

3. **Block Name Must Match**: The name after `dynamic` must exactly match the nested block type in the resource schema.

4. **Can't Use Both**: You can't have both a static block and a dynamic block of the same type in the same resource.

5. **Nested Dynamic Blocks**: Dynamic blocks can be nested inside other dynamic blocks if needed.

#### Troubleshooting Dynamic Blocks

**Error: "Unknown block type"**
- The block name doesn't match the resource schema
- Check the resource documentation for correct block names

**Error: "each.key cannot be used here"**
- You're trying to use `each` outside the `content` block
- Or you're using the wrong variable name (should be `each` or the block name)

**Blocks Not Created**
- Check that `for_each` collection is not empty
- Verify the collection has the expected structure

**Note:** In dynamic blocks, when iterating over a map, you can use either:
- `each.key` and `each.value` (recommended)
- `block_name.key` and `block_name.value` (also works, but `each` is clearer)

---

## Common Use Cases

### Use Case 1: Multiple Subnets

```hcl
# variables.tf
variable "subnets" {
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
  }))
  
  default = {
    "frontend" = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
    "backend" = {
      address_prefix    = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
    "database" = {
      address_prefix    = "10.0.3.0/24"
      service_endpoints = []
    }
  }
}

# network.tf
resource "azurerm_subnet" "main" {
  for_each = var.subnets
  
  name                 = "${var.name_prefix}-${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints
}
```

### Use Case 2: Multiple Storage Accounts

```hcl
# variables.tf
variable "storage_accounts" {
  type = map(object({
    account_tier             = string
    account_replication_type = string
    access_tier              = string
    enable_https_traffic_only = bool
  }))
  
  default = {
    "app-data" = {
      account_tier              = "Standard"
      account_replication_type  = "LRS"
      access_tier               = "Hot"
      enable_https_traffic_only = true
    }
    "backup" = {
      account_tier              = "Standard"
      account_replication_type  = "GRS"
      access_tier               = "Cool"
      enable_https_traffic_only = true
    }
  }
}

# storage.tf
resource "azurerm_storage_account" "main" {
  for_each = var.storage_accounts
  
  name                     = "${var.name_prefix}${each.key}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  access_tier              = each.value.access_tier
  enable_https_traffic_only = each.value.enable_https_traffic_only
  
  tags = {
    Purpose = each.key
  }
}
```

### Use Case 3: Multiple Virtual Machines

```hcl
# variables.tf
variable "virtual_machines" {
  type = map(object({
    vm_size        = string
    admin_username = string
    subnet_key     = string
    public_ip      = bool
  }))
  
  default = {
    "web-1" = {
      vm_size        = "Standard_B2s"
      admin_username = "azureuser"
      subnet_key     = "frontend"
      public_ip      = true
    }
    "app-1" = {
      vm_size        = "Standard_D2s_v3"
      admin_username = "azureuser"
      subnet_key     = "backend"
      public_ip      = false
    }
  }
}

# vm.tf
resource "azurerm_public_ip" "vm" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if v.public_ip == true
  }
  
  name                = "${each.key}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm" {
  for_each = var.virtual_machines
  
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = each.value.public_ip ? azurerm_public_ip.vm[each.key].id : null
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.virtual_machines
  
  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = each.value.vm_size
  admin_username      = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]
  
  # ... rest of VM configuration
}
```

---

## Best Practices

### 1. Use Meaningful Keys

✅ **Good:**
```hcl
storage_accounts = {
  "app-data" = { ... }
  "backup"   = { ... }
}
```

❌ **Bad:**
```hcl
storage_accounts = {
  "sa1" = { ... }
  "sa2" = { ... }
}
```

### 2. Validate Variable Types

```hcl
variable "storage_accounts" {
  type = map(object({
    account_tier = string
    replication_type = string
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.storage_accounts : contains(["Standard", "Premium"], v.account_tier)
    ])
    error_message = "account_tier must be Standard or Premium"
  }
}
```

### 3. Use Locals for Transformations

```hcl
variable "environments" {
  type = map(string)
}

locals {
  # Add computed values
  environments_enhanced = {
    for k, v in var.environments : k => {
      region      = v
      name_prefix = "${var.project_name}-${k}"
      tags = {
        Environment = k
        Region      = v
      }
    }
  }
}
```

### 4. Provide Sensible Defaults

```hcl
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
  
  default = {
    "default" = {
      address_prefix = "10.0.1.0/24"
    }
  }
  
  description = "Map of subnets to create. Key is subnet name."
}
```

### 5. Document Complex Structures

```hcl
variable "virtual_machines" {
  type = map(object({
    vm_size        = string        # Azure VM size (e.g., Standard_B2s)
    admin_username = string        # Admin username (3-20 chars)
    subnet_key     = string        # Key from var.subnets map
    public_ip      = bool          # Whether to create public IP
    tags           = map(string)  # Additional tags
  }))
  
  description = <<-EOT
    Map of virtual machines to create.
    
    Example:
    {
      "web-1" = {
        vm_size        = "Standard_B2s"
        admin_username = "azureuser"
        subnet_key     = "frontend"
        public_ip      = true
        tags           = { Role = "WebServer" }
      }
    }
  EOT
}
```

### 6. Use for Expressions in Outputs

```hcl
# Transform output format
output "storage_account_details" {
  value = {
    for k, v in azurerm_storage_account.main : k => {
      name         = v.name
      primary_endpoint = v.primary_blob_endpoint
      access_tier  = v.access_tier
    }
  }
}

# Filter outputs
output "public_storage_accounts" {
  value = {
    for k, v in azurerm_storage_account.main : k => v.name
    if v.public_network_access_enabled == true
  }
}
```

---

## Troubleshooting

### Error: "for_each value must be a map, or set"

**Problem:**
```hcl
variable "items" {
  type = list(string)
  default = ["item1", "item2"]
}

resource "azurerm_example" "main" {
  for_each = var.items  # ❌ Error!
}
```

**Solution:** Convert list to map or set:
```hcl
# Option 1: Convert to map
locals {
  items_map = {
    for idx, item in var.items : item => {
      index = idx
    }
  }
}

resource "azurerm_example" "main" {
  for_each = local.items_map
}

# Option 2: Use toset()
resource "azurerm_example" "main" {
  for_each = toset(var.items)
}
```

### Error: "each.key cannot be used in this context"

**Problem:** Trying to use `each.key` outside of a `for_each` block.

**Solution:** Use the resource reference instead:
```hcl
# ❌ Wrong
output "example" {
  value = each.key
}

# ✅ Correct
output "example" {
  value = {
    for k, v in azurerm_example.main : k => k
  }
}
```

### Error: "Invalid index"

**Problem:** Referencing a resource that doesn't exist:
```hcl
azurerm_storage_account.main["nonexistent"]
```

**Solution:** Check the key exists in your variable:
```hcl
# Check what keys exist
output "available_keys" {
  value = keys(var.storage_accounts)
}
```

### Error: "Cannot use for_each on resource that uses count"

**Problem:** Can't use both `count` and `for_each` on the same resource.

**Solution:** Choose one approach:
```hcl
# ❌ Wrong
resource "azurerm_example" "main" {
  count    = 2
  for_each = var.items
}

# ✅ Correct - Use for_each
resource "azurerm_example" "main" {
  for_each = var.items
}
```

### Map Key Conflicts

**Problem:** Duplicate keys in map:
```hcl
variable "items" {
  default = {
    "same-key" = "value1"
    "same-key" = "value2"  # ❌ Duplicate key
  }
}
```

**Solution:** Ensure all keys are unique. Terraform will error if duplicates exist.

---

## Summary

**Key Takeaways:**

1. **for_each** creates multiple resource instances from a map or set
2. **each.key** = the map key (or set value)
3. **each.value** = the map value (or set value)
4. **Maps** are preferred over sets for named resources
5. **Use for_each** when you need dynamic, named resources
6. **Use count** for simple conditionals or fixed numbers
7. **Validate** complex variable structures
8. **Use locals** to transform data before for_each
9. **Document** complex variable structures
10. **Test** with small examples before scaling up

**Next Steps:**
- Practice with simple maps
- Move to complex object maps
- Combine with dynamic blocks
- Use in real-world scenarios

---

## Additional Resources

- [Terraform for_each Documentation](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Terraform Variable Types](https://www.terraform.io/docs/language/values/variables.html#type-constraints)
- [Terraform for Expressions](https://www.terraform.io/docs/language/expressions/for.html)

