# Exercise 11 Answer: Composite Module

## Solution: Complete Infrastructure Module

### Module Structure

```
modules/complete-infrastructure/
├── main.tf
├── variables.tf
├── output.tf
└── README.md
```

### modules/complete-infrastructure/variables.tf

```hcl
variable "environment_name" {
  type        = string
  description = "Name of the environment (e.g., dev, staging, prod)."
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be created."
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID."
}

variable "create_aks" {
  type        = bool
  description = "Whether to create an AKS cluster."
  default     = true
}

variable "create_keyvault" {
  type        = bool
  description = "Whether to create a Key Vault."
  default     = true
}

variable "create_storage_account" {
  type        = bool
  description = "Whether to create a storage account."
  default     = false
}

# Optional: Allow customization of child modules
variable "aks_config" {
  type = object({
    kubernetes_version = optional(string)
    node_count_min     = optional(number, 1)
    node_count_max     = optional(number, 3)
    vm_size            = optional(string, "Standard_DS2_v2")
  })
  description = "Configuration for AKS cluster."
  default     = {}
}

variable "keyvault_config" {
  type = object({
    sku_name                  = optional(string, "premium")
    soft_delete_retention_days = optional(number, 7)
  })
  description = "Configuration for Key Vault."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}
```

### modules/complete-infrastructure/main.tf

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment_name}-resources"
  location = var.location

  tags = merge(
    var.tags,
    {
      Environment = var.environment_name
      ManagedBy   = "Terraform"
    }
  )
}

# Service Principal Module
module "service_principal" {
  source = "../ServicePrincipal"

  service_principal_name = "${var.environment_name}-sp"
}

# Role Assignment
resource "azurerm_role_assignment" "sp_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = module.service_principal.service_principal_object_id

  depends_on = [module.service_principal]
}

# Key Vault Module (Conditional)
module "keyvault" {
  count = var.create_keyvault ? 1 : 0

  source = "../keyvault"

  keyvault_name               = "${var.environment_name}-kv-${substr(md5(var.subscription_id), 0, 8)}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  service_principal_name       = module.service_principal.service_principal_name
  service_principal_object_id = module.service_principal.service_principal_object_id
  service_principal_tenant_id = module.service_principal.service_principal_tenant_id

  depends_on = [module.service_principal]
}

# Key Vault Secret (if Key Vault created)
resource "azurerm_key_vault_secret" "sp_secret" {
  count        = var.create_keyvault ? 1 : 0
  name         = module.service_principal.client_id
  value        = module.service_principal.client_secret
  key_vault_id = module.keyvault[0].keyvault_id

  depends_on = [module.keyvault]
}

# AKS Module (Conditional)
module "aks" {
  count = var.create_aks ? 1 : 0

  source = "../aks"

  service_principal_name = module.service_principal.service_principal_name
  client_id              = module.service_principal.client_id
  client_secret          = module.service_principal.client_secret
  location               = var.location
  resource_group_name    = azurerm_resource_group.main.name

  depends_on = [module.service_principal]
}

# Storage Account Module (Conditional) - if module exists
module "storage_account" {
  count = var.create_storage_account ? 1 : 0

  source = "../storage-account"

  storage_account_name    = "${var.environment_name}sa${substr(md5(var.subscription_id), 0, 8)}"
  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}
```

### modules/complete-infrastructure/output.tf

```hcl
# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.main.id
}

# Service Principal Outputs
output "service_principal_client_id" {
  description = "The client ID of the service principal."
  value       = module.service_principal.client_id
}

output "service_principal_object_id" {
  description = "The object ID of the service principal."
  value       = module.service_principal.service_principal_object_id
}

output "service_principal_tenant_id" {
  description = "The tenant ID of the service principal."
  value       = module.service_principal.service_principal_tenant_id
}

# Key Vault Outputs (Conditional)
output "key_vault_id" {
  description = "The ID of the Key Vault (if created)."
  value       = var.create_keyvault ? module.keyvault[0].keyvault_id : null
}

output "key_vault_uri" {
  description = "The URI of the Key Vault (if created)."
  value       = var.create_keyvault ? module.keyvault[0].keyvault_uri : null
}

# AKS Outputs (Conditional)
output "aks_cluster_name" {
  description = "The name of the AKS cluster (if created)."
  value       = var.create_aks ? module.aks[0].cluster_name : null
}

output "kubeconfig" {
  description = "The Kubernetes configuration (if AKS created)."
  value       = var.create_aks ? module.aks[0].config : null
  sensitive   = true
}

# Storage Account Outputs (Conditional)
output "storage_account_id" {
  description = "The ID of the storage account (if created)."
  value       = var.create_storage_account ? module.storage_account[0].storage_account_id : null
}
```

## Usage Example

### Root main.tf

```hcl
module "infrastructure" {
  source = "./modules/complete-infrastructure"

  environment_name = "prod"
  location         = "canadacentral"
  subscription_id  = var.SUB_ID

  create_aks         = true
  create_keyvault    = true
  create_storage_account = false

  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### terraform.tfvars

```hcl
SUB_ID = "your-subscription-id"
```

## Answers to Questions

### What's the benefit of composite modules?

**Benefits:**
1. **Simplified Interface:** Single module call instead of multiple
2. **Consistency:** Ensures resources are created together correctly
3. **Reusability:** Complete infrastructure pattern reusable across environments
4. **Abstraction:** Hides complexity of individual modules
5. **Dependency Management:** Handles all dependencies automatically
6. **Environment Templates:** Create standard infrastructure patterns

### How do you handle optional child modules?

**Answer:** Use `count` or `for_each` with conditional logic:

```hcl
# Using count
module "optional_module" {
  count = var.create_module ? 1 : 0
  source = "../module"
  # ...
}

# Reference with index
output "module_output" {
  value = var.create_module ? module.optional_module[0].output : null
}
```

**Best Practices:**
- Use boolean variables for on/off
- Use `try()` for safe references
- Provide sensible defaults
- Document what happens when optional modules aren't created

### When is module composition appropriate?

**Appropriate When:**
1. **Standard Patterns:** Common infrastructure patterns used repeatedly
2. **Environment Templates:** Dev, staging, prod environments
3. **Complete Solutions:** Full application infrastructure
4. **Team Standards:** Enforcing organizational standards
5. **Complex Dependencies:** Many interdependent modules

**Not Appropriate When:**
1. **One-Time Use:** Unique infrastructure that won't be reused
2. **Too Specific:** Very environment-specific requirements
3. **Over-Abstraction:** Hiding too much complexity
4. **Frequent Changes:** Modules change independently often

## Advanced: Nested Module Composition

### Example: Multi-Environment Module

```hcl
# modules/environments/production/main.tf
module "infrastructure" {
  source = "../../complete-infrastructure"

  environment_name = "prod"
  location         = "canadacentral"
  subscription_id  = var.subscription_id

  create_aks         = true
  create_keyvault    = true
  create_storage_account = true

  tags = {
    Environment = "production"
    Criticality = "high"
  }
}
```

## Testing the Composite Module

### Test 1: Create Everything

```hcl
module "infrastructure" {
  source = "./modules/complete-infrastructure"
  
  environment_name = "test"
  location         = "canadacentral"
  subscription_id  = var.SUB_ID
  
  create_aks         = true
  create_keyvault    = true
  create_storage_account = true
}
```

```bash
terraform init
terraform plan
# Should show all resources
```

### Test 2: Minimal Infrastructure

```hcl
module "infrastructure" {
  source = "./modules/complete-infrastructure"
  
  environment_name = "test"
  location         = "canadacentral"
  subscription_id  = var.SUB_ID
  
  create_aks         = false
  create_keyvault    = false
  create_storage_account = false
}
```

```bash
terraform plan
# Should only show resource group and service principal
```

## Best Practices for Composite Modules

1. **Clear Interface:** Simple, well-documented inputs
2. **Sensible Defaults:** Defaults that work for most cases
3. **Conditional Creation:** Allow optional components
4. **Comprehensive Outputs:** Expose all important values
5. **Documentation:** Clear README with examples
6. **Testing:** Test with different configurations
7. **Versioning:** Version composite modules like any module

## Common Patterns

### Pattern 1: Environment Module
```hcl
# Complete environment in one module
module "environment" {
  source = "./modules/environment"
  environment = "prod"
  # ...
}
```

### Pattern 2: Application Module
```hcl
# Complete application infrastructure
module "application" {
  source = "./modules/application"
  app_name = "myapp"
  # ...
}
```

### Pattern 3: Platform Module
```hcl
# Complete platform (networking, security, etc.)
module "platform" {
  source = "./modules/platform"
  # ...
}
```

## Summary

Composite modules are powerful for:
- Standardizing infrastructure patterns
- Simplifying complex deployments
- Ensuring consistency
- Reducing errors through automation

Use them when you have reusable infrastructure patterns that benefit from a single, simplified interface.

