# Terragrunt Guide

## Installation

### macOS
```bash
brew install terragrunt
```

### Linux
```bash
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.50.0/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
```

### Verify Installation
```bash
terragrunt --version
```

## Basic Commands

### Initialize
```bash
cd environments/dev
terragrunt init
```

### Plan
```bash
terragrunt plan
```

### Apply
```bash
terragrunt apply
```

### Destroy
```bash
terragrunt destroy
```

## Run All Commands

Execute commands across all environments:

```bash
# From root directory
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy
```

## Configuration Structure

### Root Configuration (terragrunt.hcl)
- Common settings
- Remote state configuration
- Provider generation
- Default inputs

### Environment Configuration
- Inherits from root using `include`
- Overrides environment-specific values
- Can add hooks and dependencies

## Key Features

### 1. DRY (Don't Repeat Yourself)
- Centralize common configuration
- Inherit and override as needed

### 2. Dependency Management
```hcl
dependency "network" {
  config_path = "../network"
}

inputs = {
  vnet_id = dependency.network.outputs.vnet_id
}
```

### 3. Hooks
```hcl
terraform {
  before_hook "validate" {
    commands = ["apply"]
    execute  = ["bash", "scripts/validate.sh"]
  }
}
```

### 4. Generate Blocks
Automatically generate Terraform files:
```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}
```

## Best Practices

1. **Use include for inheritance**
2. **Keep root configuration minimal**
3. **Override only what's necessary**
4. **Use dependencies for module references**
5. **Document environment-specific overrides**
6. **Use hooks for validation and automation**

## Terragrunt vs Native Terraform

### Terragrunt Advantages
- DRY configuration
- Built-in dependency management
- Hooks for automation
- Workspace management
- Remote state management

### When to Use Terragrunt
- Multiple environments with similar configurations
- Need for dependency management
- Want to reduce code duplication
- Need hooks for automation

### When to Use Native Terraform
- Simple single-environment deployments
- Prefer Terraform-native features
- Don't want additional tooling
- Team unfamiliar with Terragrunt

