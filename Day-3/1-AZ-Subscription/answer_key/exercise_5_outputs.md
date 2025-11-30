# Exercise 5 Answer: Module Outputs and Root Module Usage

## Solution: Enhanced Root Outputs

### Updated output.tf

```hcl
# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg1.name
}

output "resource_group_location" {
  description = "The location of the resource group."
  value       = azurerm_resource_group.rg1.location
}

# Service Principal Outputs
output "service_principal_client_id" {
  description = "The application (client) ID of the Azure AD service principal."
  value       = module.ServicePrincipal.client_id
}

output "service_principal_client_secret" {
  description = "The client secret (password) for the service principal. This is sensitive."
  value       = module.ServicePrincipal.client_secret
  sensitive   = true
}

output "service_principal_object_id" {
  description = "The object ID of the service principal. Used for role assignments."
  value       = module.ServicePrincipal.service_principal_object_id
}

output "service_principal_tenant_id" {
  description = "The tenant ID of the service principal."
  value       = module.ServicePrincipal.service_principal_tenant_id
}

# Key Vault Outputs
output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = module.keyvault.keyvault_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault for accessing secrets."
  value       = module.keyvault.keyvault_uri
}

# AKS Outputs
output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = try(module.aks.cluster_name, null)
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = try(module.aks.cluster_fqdn, null)
}

output "kubeconfig" {
  description = "The Kubernetes configuration file content. This is sensitive."
  value       = try(module.aks.config, null)
  sensitive   = true
}

# Storage Account Outputs (if created)
output "storage_account_id" {
  description = "The ID of the storage account (if created)."
  value       = try(module.storage_account.storage_account_id, null)
}

output "storage_account_name" {
  description = "The name of the storage account (if created)."
  value       = try(module.storage_account.storage_account_name, null)
}

output "storage_account_primary_blob_endpoint" {
  description = "The endpoint URL for blob storage (if created)."
  value       = try(module.storage_account.primary_blob_endpoint, null)
}
```

### Note: Update AKS Module Outputs

**modules/aks/output.tf** (add these outputs):
```hcl
output "config" {
  description = "The Kubernetes configuration file content."
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks-cluster.name
}

output "cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.aks-cluster.fqdn
}
```

## Answers to Questions

### Why expose outputs from the root module instead of accessing modules directly?
- **Answer:** 
  1. **Abstraction:** Root module provides a clean interface, hiding internal module structure
  2. **Consistency:** Single place to get all important values
  3. **Documentation:** Root outputs document what's important to users
  4. **Flexibility:** Can transform or combine module outputs before exposing
  5. **Stability:** Module structure can change without breaking user code

### When should outputs be marked as sensitive?
- **Answer:** Mark outputs as sensitive when they contain:
  - Passwords or secrets
  - API keys or access keys
  - Private keys or certificates
  - Personal identifiable information (PII)
  - Any data that shouldn't appear in logs or UI

### How can outputs be used by other tools or scripts?
- **Answer:** 
  1. **CLI Access:**
     ```bash
     terraform output -json > outputs.json
     terraform output key_vault_uri
     ```
  2. **CI/CD Pipelines:**
     ```bash
     export KUBECONFIG=$(terraform output -raw kubeconfig)
     kubectl get nodes
     ```
  3. **Other Terraform Configurations:**
     ```hcl
     data "terraform_remote_state" "main" {
       backend = "azurerm"
       # ...
     }
     key_vault_id = data.terraform_remote_state.main.outputs.key_vault_id
     ```
  4. **Scripts:**
     ```bash
     #!/bin/bash
     CLIENT_ID=$(terraform output -raw service_principal_client_id)
     echo "Using client ID: $CLIENT_ID"
     ```

## Testing Outputs

### View All Outputs
```bash
terraform output
```

### View Specific Output
```bash
terraform output key_vault_uri
terraform output service_principal_client_id
```

### View as JSON
```bash
terraform output -json
```

### View Sensitive Outputs
```bash
# Sensitive outputs require -json flag
terraform output -json | jq '.kubeconfig.value'
```

### Use in Scripts
```bash
#!/bin/bash
KEY_VAULT_URI=$(terraform output -raw key_vault_uri)
echo "Key Vault URI: $KEY_VAULT_URI"

# Save kubeconfig
terraform output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
```

## Output Organization Best Practices

1. **Group Related Outputs:** Use comments to group outputs by module/resource
2. **Descriptive Names:** Use clear, consistent naming conventions
3. **Add Descriptions:** Every output should have a description
4. **Mark Sensitive:** Always mark sensitive outputs
5. **Use try() for Optional:** Use `try()` for outputs that might not exist
6. **Document Usage:** Include examples in descriptions

## Example: Using Outputs in CI/CD

```yaml
# GitHub Actions example
- name: Get Terraform Outputs
  id: terraform-outputs
  run: |
    echo "key_vault_uri=$(terraform output -raw key_vault_uri)" >> $GITHUB_OUTPUT
    echo "cluster_name=$(terraform output -raw aks_cluster_name)" >> $GITHUB_OUTPUT

- name: Configure kubectl
  run: |
    terraform output -raw kubeconfig > kubeconfig.yaml
    export KUBECONFIG=./kubeconfig.yaml
    kubectl get nodes
```

