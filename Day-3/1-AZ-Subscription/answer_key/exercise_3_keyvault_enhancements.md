# Exercise 3 Answer: KeyVault Module Enhancements

## Solution: Enhanced KeyVault Module

### modules/keyvault/variables.tf (Updated)

```hcl
variable "keyvault_name" {
  type        = string
  description = "The name of the Key Vault. Must be globally unique."
}

variable "location" {
  type        = string
  description = "The Azure region where the Key Vault will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Key Vault will be created."
}

variable "service_principal_name" {
  type        = string
  description = "The name of the service principal (for reference)."
}

variable "service_principal_object_id" {
  type        = string
  description = "The object ID of the service principal for access policies."
}

variable "service_principal_tenant_id" {
  type        = string
  description = "The tenant ID of the service principal."
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault."
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the Key Vault."
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days that items should be retained for once soft-deleted. Valid values are between 7 and 90."
  default     = 7
}
```

### modules/keyvault/main.tf (Updated)

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_deployment      = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  sku_name                    = "premium"
  soft_delete_retention_days  = var.soft_delete_retention_days
  enable_rbac_authorization   = true
}
```

### modules/keyvault/output.tf (Updated)

```hcl
output "keyvault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "keyvault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}
```

## Answers to Questions

### Why use variables with defaults instead of hardcoding values?
- **Answer:** Variables with defaults provide flexibility while maintaining sensible defaults. They allow users to customize behavior without requiring them to specify every option, and make the module more reusable across different scenarios.

### What's the benefit of making these configurable?
- **Answer:** Different use cases require different Key Vault configurations. For example:
  - Development environments might not need disk encryption
  - Production might need longer retention periods
  - Some deployments need template deployment enabled
  Making these configurable allows one module to serve multiple purposes.

### How does changing a module affect existing infrastructure?
- **Answer:** When you update a module:
  1. Run `terraform init -upgrade` to refresh module sources
  2. Run `terraform plan` to see what changes
  3. Terraform will update resources if the changes require it
  4. If changes are incompatible, Terraform may require resource replacement
  5. Always review the plan carefully before applying

## Testing

```bash
# Refresh modules
terraform init -upgrade

# Plan to see changes
terraform plan

# Should show updates to Key Vault resource with new properties
```

## Usage Example

```hcl
module "keyvault" {
  source                      = "./modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_name      = var.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id
  
  # New optional variables
  enabled_for_deployment           = true
  enabled_for_template_deployment  = true
  soft_delete_retention_days       = 30
}
```

