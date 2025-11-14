# State Management Guide

## State Migration

### Local to Remote Backend
```bash
# 1. Update backend.tf with remote backend configuration
# 2. Initialize with migration
terraform init -migrate-state
# 3. Verify migration
terraform plan
```

### Between Remote Backends
```bash
# 1. Pull current state
terraform state pull > state-backup.json
# 2. Update backend configuration
# 3. Initialize with migration
terraform init -migrate-state
# 4. Verify
terraform plan
```

## Workspace Management

### Create and Switch Workspaces
```bash
# Create new workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

### Workspace-Specific Configuration
Use `terraform.workspace` variable in your configuration:
```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-${terraform.workspace}-example"
  location = var.location
}
```

## State Manipulation

### List Resources
```bash
terraform state list
```

### Show Resource Details
```bash
terraform state show azurerm_resource_group.example
```

### Move Resource
```bash
terraform state mv azurerm_resource_group.old azurerm_resource_group.new
```

### Remove Resource from State
```bash
terraform state rm azurerm_resource_group.example
```

### Backup State
```bash
terraform state pull > state-backup-$(date +%Y%m%d).json
```

## Remote State Data Source

### Access Remote State
```hcl
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "network.terraform.tfstate"
  }
}

# Use outputs
resource "azurerm_subnet" "example" {
  virtual_network_name = data.terraform_remote_state.network.outputs.vnet_name
  # ...
}
```

## Best Practices

1. **Always backup state before manipulation**
2. **Use remote backends for production**
3. **Enable state locking**
4. **Use workspaces for environment separation**
5. **Document state structure**
6. **Version control state files (if local) with caution**

