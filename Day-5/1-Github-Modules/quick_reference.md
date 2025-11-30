# Quick Reference: Publishing Modules to GitHub

## Quick Commands

### Create GitHub Repository

```bash
# Using GitHub CLI
gh repo create terraform-azurerm-vm \
  --public \
  --description "Terraform module for Azure Linux VM with networking"
```

### Initialize and Push Module

```bash
# Navigate to module directory
cd modules/vm

# Initialize Git
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: Azure VM module"

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/terraform-azurerm-vm.git

# Push
git branch -M main
git push -u origin main
```

### Create Version Tag and Release

```bash
# Create tag
git tag -a v1.0.0 -m "Initial release"

# Push tag
git push origin v1.0.0

# Create release
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Initial release of Azure VM module"
```

### Use Module from GitHub

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "myvm"
  resource_group_name = "my-rg"
  location           = "eastus"
}
```

## Module Source Formats

```hcl
# Specific version (recommended)
source = "github.com/username/repo?ref=v1.0.0"

# Branch
source = "github.com/username/repo?ref=main"

# Commit SHA
source = "github.com/username/repo?ref=abc123def456"

# Default branch (not recommended)
source = "github.com/username/repo"
```

## Required Files for GitHub Module

- ✅ `main.tf` - Main module resources
- ✅ `variables.tf` - Input variables
- ✅ `outputs.tf` - Output values
- ✅ `README.md` - Module documentation
- ✅ `.gitignore` - Git ignore rules
- ✅ `LICENSE` - License file (optional)

## Semantic Versioning

- **Major** (v2.0.0): Breaking changes
- **Minor** (v1.1.0): New features, backward compatible
- **Patch** (v1.0.1): Bug fixes, backward compatible

## Troubleshooting

### Module not found
```bash
# Verify repository exists
gh repo view username/repo

# Clear Terraform cache
rm -rf .terraform
terraform init
```

### Authentication required
```bash
# Setup Git credentials
gh auth setup-git

# Or use SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### Update module version
```bash
# Upgrade module
terraform init -upgrade

# Or clear cache and reinit
rm -rf .terraform/modules
terraform init
```

