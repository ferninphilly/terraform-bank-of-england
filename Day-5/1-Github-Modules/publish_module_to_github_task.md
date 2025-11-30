# Task: Publish Terraform Module to GitHub

This task teaches you how to publish a Terraform module to GitHub and use it from other Terraform configurations. You'll take the VM module with alerts and networking from Day 4 and publish it as a reusable GitHub module.

## Learning Objectives

By the end of this task, you will:
- Understand how to structure a module for GitHub publication
- Create a GitHub repository for your Terraform module
- Publish modules to GitHub with proper versioning
- Use modules from GitHub in your Terraform code
- Understand module versioning and semantic versioning
- Learn best practices for module repositories

## Prerequisites

Before starting, ensure you have:
- ✅ Completed GitHub authentication (from Day 5, Step 1)
- ✅ GitHub CLI (`gh`) installed and authenticated
- ✅ Git configured with your GitHub credentials
- ✅ Access to the VM module from Day 4 (`Day-4/3-Review-Modules/answer_key_vm/`)

## Task Overview

You'll be publishing the VM module with alerts and networking to GitHub, then using it from another Terraform configuration. This demonstrates:
1. Module publication workflow
2. Module versioning
3. Using modules from remote sources
4. Module inheritance and composition

---

## Step 1: Prepare Your Module for GitHub

Before publishing, we need to ensure the module is properly structured for GitHub.

### Module Structure Requirements

A GitHub-ready Terraform module should have:
- ✅ Clear directory structure
- ✅ Comprehensive `README.md` with usage examples
- ✅ Proper `variables.tf` with descriptions
- ✅ Complete `outputs.tf` with descriptions
- ✅ Example `terraform.tfvars.example` file
- ✅ `.gitignore` file
- ✅ License file (optional but recommended)

### Check Current Module Structure

Navigate to the VM module:

```bash
cd Day-4/3-Review-Modules/answer_key_vm
ls -la modules/
```

You should see:
```
modules/
├── vm/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── vm-alerts/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

**Note:** For GitHub modules, you typically publish **one module per repository**. We'll publish the VM module first, then optionally the alerts module.

---

## Step 2: Create a New GitHub Repository

### Option 1: Using GitHub CLI (Recommended)

```bash
# Navigate to your module directory
cd Day-4/3-Review-Modules/answer_key_vm/modules/vm

# Create a new GitHub repository
gh repo create terraform-azurerm-vm \
  --public \
  --description "Terraform module for Azure Linux VM with networking" \
  --clone=false

# Expected output:
# ✓ Created repository YOUR_USERNAME/terraform-azurerm-vm on GitHub
```

**Repository naming convention:**
- Use `terraform-azurerm-<resource-name>` format
- This follows HashiCorp's naming convention
- Makes it easy to find and understand the module's purpose

### Option 2: Using GitHub Website

1. Go to https://github.com/new
2. Repository name: `terraform-azurerm-vm`
3. Description: "Terraform module for Azure Linux VM with networking"
4. Choose Public or Private
5. **Don't** initialize with README, .gitignore, or license (we'll add these)
6. Click "Create repository"

---

## Step 3: Initialize Git Repository

If the module directory isn't already a Git repository:

```bash
# Navigate to module directory
cd Day-4/3-Review-Modules/answer_key_vm/modules/vm

# Initialize Git repository
git init

# Check status
git status
```

---

## Step 4: Create Module Documentation

Create a comprehensive `README.md` for your module. You can use the template provided in `module_readme_template.md` or create your own:

```bash
# Option 1: Copy template (if available)
cp ../../module_readme_template.md README.md
# Then edit with your details

# Option 2: Create from scratch
cat > README.md << 'EOF'
# terraform-azurerm-vm

Terraform module for creating Azure Linux Virtual Machines with complete networking infrastructure.

## Features

- ✅ Virtual Network and Subnet creation
- ✅ Public IP Address allocation
- ✅ Network Security Group with SSH and HTTP rules
- ✅ Network Interface Card configuration
- ✅ Linux Virtual Machine (Ubuntu 22.04 LTS)
- ✅ Configurable VM sizes
- ✅ SSH key authentication

## Usage

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "myvm"
  resource_group_name = "my-rg"
  location           = "eastus"
  vm_size            = "Standard_B2s"
  admin_username     = "azureuser"
  ssh_public_key     = "~/.ssh/id_rsa.pub"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | string | - | yes |
| resource_group_name | Name of the resource group | string | - | yes |
| location | Azure region | string | - | yes |
| vm_size | VM size (e.g., Standard_B2s) | string | "Standard_B2s" | no |
| admin_username | Admin username for VM | string | "azureuser" | no |
| ssh_public_key | Path to SSH public key | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | ID of the virtual machine |
| vm_name | Name of the virtual machine |
| vm_public_ip | Public IP address of the VM |
| vm_private_ip | Private IP address of the VM |
| vnet_id | ID of the virtual network |
| subnet_id | ID of the subnet |

## Examples

See [examples/](./examples/) directory for more usage examples.

## License

MIT License
EOF
```

---

## Step 5: Create .gitignore File

Create a `.gitignore` file to exclude unnecessary files:

```bash
cat > .gitignore << 'EOF'
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
*tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc

# IDE files
.idea/
.vscode/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
EOF
```

---

## Step 6: Add Files and Commit

```bash
# Add all files
git add .

# Check what will be committed
git status

# Create initial commit
git commit -m "Initial commit: Azure VM module with networking"

# Verify commit
git log --oneline
```

---

## Step 7: Add Remote and Push to GitHub

```bash
# Add GitHub repository as remote
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/terraform-azurerm-vm.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main

# Expected output:
# Enumerating objects: X, done.
# Counting objects: 100% (X/X), done.
# Writing objects: 100% (X/X), done.
# To https://github.com/YOUR_USERNAME/terraform-azurerm-vm.git
#  * [new branch]      main -> main
```

**Alternative: Using SSH**

If you have SSH keys configured:

```bash
git remote add origin git@github.com:YOUR_USERNAME/terraform-azurerm-vm.git
git push -u origin main
```

---

## Step 8: Create a Release Tag (Versioning)

Terraform modules from GitHub should use version tags. Let's create the first release:

```bash
# Create an annotated tag for version 1.0.0
git tag -a v1.0.0 -m "Initial release: VM module with networking"

# Push tags to GitHub
git push origin v1.0.0

# Verify tag
git tag -l
```

**Semantic Versioning:**
- `v1.0.0` - Major.Minor.Patch
- Major: Breaking changes
- Minor: New features, backward compatible
- Patch: Bug fixes, backward compatible

### Create Release on GitHub

```bash
# Create a release using GitHub CLI
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "Initial release of Azure VM module with networking infrastructure.

Features:
- Virtual Network and Subnet
- Public IP Address
- Network Security Group
- Network Interface
- Linux Virtual Machine

See README.md for usage examples."
```

**Or via GitHub Website:**
1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Release title: "v1.0.0 - Initial Release"
5. Add release notes
6. Click "Publish release"

---

## Step 9: Use Module from GitHub

Now let's use the module from GitHub in a new Terraform configuration.

### Create a New Configuration

```bash
# Navigate to Day-5/Github-Modules
cd Day-5/Github-Modules

# Create a new directory for testing
mkdir -p test-module-usage
cd test-module-usage
```

### Create main.tf

```bash
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Use module from GitHub
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "testvm"
  resource_group_name = "test-vm-rg"
  location           = "eastus"
  vm_size            = "Standard_B2s"
  admin_username     = "azureuser"
  ssh_public_key     = file("~/.ssh/id_rsa.pub")
  
  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
    Module      = "GitHub"
  }
}

# Output module outputs
output "vm_public_ip" {
  value = module.vm.vm_public_ip
}

output "vm_name" {
  value = module.vm.vm_name
}
EOF
```

**Important:** Replace `YOUR_USERNAME` with your actual GitHub username!

### Initialize Terraform

```bash
# Initialize Terraform (will download module from GitHub)
terraform init

# Expected output:
# Initializing modules...
# - vm in
#   Downloading github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0 for vm...
#   - vm in .terraform/modules/vm
# ...
```

### Plan and Apply

```bash
# Review plan
terraform plan

# Apply (if plan looks good)
terraform apply
```

---

## Step 10: Understanding Module Source Syntax

### GitHub Module Source Formats

Terraform supports several ways to reference GitHub modules:

#### 1. **Using Specific Version Tag** (Recommended)
```hcl
source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
```
- Uses a specific version tag
- Most stable and predictable
- Recommended for production

#### 2. **Using Branch**
```hcl
source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=main"
```
- Uses latest commit from branch
- Can change unexpectedly
- Good for development/testing

#### 3. **Using Commit SHA**
```hcl
source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=abc123def456"
```
- Uses specific commit
- Most specific, but hard to read
- Good for pinning exact versions

#### 4. **Using Default Branch** (Not Recommended)
```hcl
source = "github.com/YOUR_USERNAME/terraform-azurerm-vm"
```
- Uses default branch (usually main)
- Can change without notice
- Not recommended for production

### Private Repositories

If your repository is private, you need to authenticate:

```bash
# Configure Git credential helper
git config --global credential.helper store

# Or use SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

---

## Step 11: Update Module and Create New Version

When you make changes to your module:

```bash
# Navigate to module directory
cd Day-4/3-Review-Modules/answer_key_vm/modules/vm

# Make changes to your module files
# ... edit main.tf, variables.tf, etc. ...

# Commit changes
git add .
git commit -m "Add support for custom image ID"

# Push changes
git push origin main

# Create new version tag
git tag -a v1.1.0 -m "Add custom image ID support"
git push origin v1.1.0

# Create release
gh release create v1.1.0 \
  --title "v1.1.0 - Custom Image Support" \
  --notes "Added support for custom VM image IDs"
```

### Update Module Usage

In your Terraform configuration using the module:

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.1.0"  # Updated version
  
  # ... rest of configuration
}
```

Then run:
```bash
terraform init -upgrade  # Upgrade module to new version
terraform plan           # Review changes
```

---

## Step 12: Publish Alerts Module (Optional)

You can also publish the alerts module separately:

```bash
# Navigate to alerts module
cd Day-4/3-Review-Modules/answer_key_vm/modules/vm-alerts

# Create GitHub repository
gh repo create terraform-azurerm-vm-alerts \
  --public \
  --description "Terraform module for Azure VM monitoring alerts"

# Initialize and push
git init
git add .
git commit -m "Initial commit: VM alerts module"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/terraform-azurerm-vm-alerts.git
git push -u origin main

# Create release
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
gh release create v1.0.0 --title "v1.0.0 - Initial Release"
```

### Use Both Modules Together

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  # ... configuration
}

module "vm_alerts" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm-alerts?ref=v1.0.0"
  
  vm_id               = module.vm.vm_id
  vm_name             = module.vm.vm_name
  resource_group_name = module.vm.resource_group_name
  # ... other configuration
}
```

---

## Best Practices

### 1. **Module Structure**
- Keep modules focused and single-purpose
- One module per repository
- Clear naming conventions

### 2. **Documentation**
- Comprehensive README.md
- Usage examples
- Input/output documentation
- Requirements section

### 3. **Versioning**
- Use semantic versioning (v1.0.0)
- Tag releases properly
- Document breaking changes

### 4. **Testing**
- Test modules before publishing
- Use example configurations
- Validate with `terraform validate`

### 5. **Security**
- Don't commit secrets
- Use `.gitignore` properly
- Review code before publishing

### 6. **Maintenance**
- Keep modules updated
- Respond to issues
- Document changes in releases

---

## Troubleshooting

### Issue: "Module not found" when running terraform init

**Solutions:**
1. **Verify repository exists:**
   ```bash
   gh repo view YOUR_USERNAME/terraform-azurerm-vm
   ```

2. **Check module source URL:**
   - Ensure username is correct
   - Verify tag/branch exists
   - Check repository is public (or you're authenticated)

3. **Clear Terraform cache:**
   ```bash
   rm -rf .terraform
   terraform init
   ```

### Issue: "Authentication required" for private repository

**Solutions:**
1. **Use SSH instead of HTTPS:**
   ```bash
   git config --global url."git@github.com:".insteadOf "https://github.com/"
   ```

2. **Configure Git credentials:**
   ```bash
   gh auth setup-git
   ```

### Issue: "Invalid module source"

**Solutions:**
1. **Check source format:**
   - Must start with `github.com/`
   - Include username and repository name
   - Use `?ref=` for version/branch

2. **Verify tag exists:**
   ```bash
   gh release list --repo YOUR_USERNAME/terraform-azurerm-vm
   ```

### Issue: Module changes not reflected

**Solutions:**
1. **Upgrade module:**
   ```bash
   terraform init -upgrade
   ```

2. **Clear module cache:**
   ```bash
   rm -rf .terraform/modules
   terraform init
   ```

---

## Summary

In this task, you learned:
- ✅ How to structure a module for GitHub publication
- ✅ How to create a GitHub repository for your module
- ✅ How to publish modules with version tags
- ✅ How to use modules from GitHub in Terraform
- ✅ Module versioning and semantic versioning
- ✅ Best practices for module repositories

## Next Steps

1. **Publish your VM module** following the steps above
2. **Create example configurations** in your module repository
3. **Add more features** to your module and create new versions
4. **Share your module** with others or use it in your projects

## Deliverables

- ✅ GitHub repository with VM module
- ✅ Tagged release (v1.0.0)
- ✅ Comprehensive README.md
- ✅ Example usage in test configuration
- ✅ Understanding of module versioning

---

## Quick Reference

```bash
# Create GitHub repository
gh repo create terraform-azurerm-vm --public --description "..."

# Initialize Git
git init
git add .
git commit -m "Initial commit"

# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/terraform-azurerm-vm.git
git push -u origin main

# Create version tag
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0

# Create release
gh release create v1.0.0 --title "v1.0.0" --notes "..."

# Use module
source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
```

