# Import Guide

## Prerequisites
- Azure CLI installed and authenticated
- Terraform installed
- Existing Azure resources to import

## Step-by-Step Import Process

### 1. Identify Resources
List resources to import and their resource IDs:
```bash
az resource list --output table
```

### 2. Create Terraform Configuration
Create matching Terraform configuration before importing.

### 3. Import Resources
Use terraform import command:
```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

### 4. Verify Import
```bash
terraform plan
```

## Common Import Commands

### Resource Group
```bash
terraform import azurerm_resource_group.example /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
```

### Storage Account
```bash
terraform import azurerm_storage_account.example /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}
```

### Virtual Network
```bash
terraform import azurerm_virtual_network.example /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}
```

## Troubleshooting

### Resource Not Found
- Verify resource ID is correct
- Check Azure CLI authentication
- Ensure resource exists in subscription

### Configuration Mismatch
- Run `terraform plan` to see differences
- Update Terraform configuration to match existing resource
- Re-run import if needed

### State Conflicts
- Use `terraform state list` to check existing state
- Use `terraform state rm` to remove conflicting resources
- Re-import with correct resource address

