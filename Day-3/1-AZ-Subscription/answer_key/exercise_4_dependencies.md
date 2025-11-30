# Exercise 4 Answer: Module Dependencies and Data Flow

## Solution: Understanding Dependencies

### Data Flow Diagram

```
┌─────────────────────────┐
│   Resource Group (rg1)   │
└───────────┬─────────────┘
            │
            ▼
┌──────────────────────────────┐
│  ServicePrincipal Module    │
│  ┌────────────────────────┐  │
│  │ Azure AD Application  │  │
│  │ Service Principal     │  │
│  │ SP Password           │  │
│  └────────────────────────┘  │
│  Outputs:                    │
│  - client_id                 │
│  - client_secret             │
│  - object_id ────────────────┼──┐
│  - tenant_id ────────────────┼──┼──┐
└──────────────────────────────┘  │  │
                                  │  │
            ┌─────────────────────┘  │
            │                        │
            ▼                        │
┌──────────────────────────────┐   │
│  Role Assignment             │   │
│  (uses object_id)           │   │
└──────────────────────────────┘   │
                                   │
            ┌──────────────────────┘
            │
            ▼
┌──────────────────────────────┐
│  KeyVault Module             │
│  ┌────────────────────────┐  │
│  │ Azure Key Vault        │  │
│  └────────────────────────┘  │
│  Outputs:                    │
│  - keyvault_id ──────────────┼──┐
└──────────────────────────────┘  │
                                  │
            ┌─────────────────────┘
            │
            ▼
┌──────────────────────────────┐
│  Key Vault Secret            │
│  (uses client_id,            │
│   client_secret, keyvault_id)│
└──────────────────────────────┘

┌──────────────────────────────┐
│  AKS Module                  │
│  ┌────────────────────────┐  │
│  │ AKS Cluster            │  │
│  └────────────────────────┘  │
│  Uses:                       │
│  - client_id                 │
│  - client_secret             │
└──────────────────────────────┘
```

### Complete Dependency Mapping

| Module/Resource | Depends On | Uses Outputs From |
|----------------|------------|-------------------|
| ServicePrincipal | Resource Group | - |
| Role Assignment | ServicePrincipal | `service_principal_object_id` |
| KeyVault | ServicePrincipal | `service_principal_object_id`, `service_principal_tenant_id` |
| Key Vault Secret | KeyVault, ServicePrincipal | `client_id`, `client_secret`, `keyvault_id` |
| AKS | ServicePrincipal | `client_id`, `client_secret` |
| Kubeconfig File | AKS | `config` |

### Solution: Adding Storage Account Dependency

#### Updated Storage Account Module

**modules/storage-account/variables.tf** (add):
```hcl
variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault where the access key will be stored."
  default     = null
}

variable "store_access_key_in_keyvault" {
  type        = bool
  description = "Whether to store the primary access key in Key Vault."
  default     = false
}
```

**modules/storage-account/main.tf** (add):
```hcl
resource "azurerm_key_vault_secret" "storage_key" {
  count        = var.store_access_key_in_keyvault && var.key_vault_id != null ? 1 : 0
  name         = "${var.storage_account_name}-primary-key"
  value        = azurerm_storage_account.main.primary_access_key
  key_vault_id = var.key_vault_id

  depends_on = [azurerm_storage_account.main]
}
```

**modules/storage-account/output.tf** (add):
```hcl
output "access_key_secret_id" {
  description = "The ID of the Key Vault secret containing the access key (if stored)."
  value       = var.store_access_key_in_keyvault && var.key_vault_id != null ? azurerm_key_vault_secret.storage_key[0].id : null
}
```

#### Updated Root main.tf

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  storage_account_name    = "mystorage${random_id.storage_suffix.hex}"
  resource_group_name     = azurerm_resource_group.rg1.name
  location                = var.location
  key_vault_id            = module.keyvault.keyvault_id
  store_access_key_in_keyvault = true

  depends_on = [
    module.keyvault
  ]
}
```

## Answers to Questions

### What's the difference between implicit and explicit dependencies?
- **Implicit Dependencies:** Created when one resource references another through variables or outputs. Terraform automatically detects these.
  ```hcl
  # Implicit - Terraform knows AKS depends on ServicePrincipal
  module "aks" {
    client_id = module.ServicePrincipal.client_id
  }
  ```

- **Explicit Dependencies:** Created using `depends_on` when there's no direct reference but order matters.
  ```hcl
  # Explicit - No direct reference but order matters
  module "aks" {
    depends_on = [module.ServicePrincipal]
  }
  ```

### When should you use `depends_on` vs. variable references?
- **Use variable references** when you actually need the value (preferred method)
- **Use `depends_on`** when:
  - There's no direct value dependency but order matters
  - Resources need to exist before others for side effects
  - You want to make dependencies explicit for clarity

### What happens if you remove a dependency that's actually needed?
- **Answer:** Terraform might try to create resources in the wrong order, causing:
  - Resource creation failures
  - "Resource not found" errors
  - Race conditions
  - Inconsistent state

## Testing Dependency Behavior

### Test 1: Remove depends_on

```hcl
# Remove this:
depends_on = [module.ServicePrincipal]

# Result: Terraform might create AKS before ServicePrincipal exists
# Error: "Service principal not found"
```

### Test 2: Add Explicit Dependency

```hcl
module "storage_account" {
  # ... variables
  depends_on = [
    module.keyvault,
    azurerm_resource_group.rg1
  ]
}
```

### Test 3: Verify Order

```bash
terraform plan | grep -E "(module|resource)" | head -20
# Should show creation order matches dependencies
```

## Best Practices

1. **Prefer Implicit Dependencies:** Use variable references when possible
2. **Use depends_on Sparingly:** Only when order matters but no value dependency
3. **Document Dependencies:** Add comments explaining why dependencies exist
4. **Test Dependency Changes:** Always plan after modifying dependencies
5. **Group Related Resources:** Keep dependent resources together

