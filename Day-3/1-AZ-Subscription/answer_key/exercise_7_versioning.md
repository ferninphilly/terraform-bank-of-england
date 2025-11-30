# Exercise 7 Answer: Module Versioning and Source Control

## Solution: Understanding Module Sources and Versioning

### Current Setup Analysis

**Current Source Type:** Local Path
```hcl
module "ServicePrincipal" {
  source = "./modules/ServicePrincipal"
}
```

**Characteristics:**
- Modules are in the same repository
- No version control
- Changes immediately affect root module
- Simple for development

---

## Git Source Examples

### GitHub Public Repository

```hcl
# Specific version tag
module "keyvault" {
  source = "git::https://github.com/org/terraform-modules.git//modules/keyvault?ref=v1.0.0"
}

# Branch reference
module "keyvault" {
  source = "git::https://github.com/org/terraform-modules.git//modules/keyvault?ref=main"
}

# Commit hash
module "keyvault" {
  source = "git::https://github.com/org/terraform-modules.git//modules/keyvault?ref=abc123def456"
}
```

### GitHub Private Repository (SSH)

```hcl
module "keyvault" {
  source = "git::git@github.com:org/terraform-modules.git//modules/keyvault?ref=v1.0.0"
}
```

### GitHub Private Repository (HTTPS with Token)

```hcl
# Set GITHUB_TOKEN environment variable
module "keyvault" {
  source = "git::https://${var.github_token}@github.com/org/terraform-modules.git//modules/keyvault?ref=v1.0.0"
}
```

### GitLab Repository

```hcl
module "keyvault" {
  source = "git::https://gitlab.com/org/terraform-modules.git//modules/keyvault?ref=v1.0.0"
}
```

### Azure DevOps Repository

```hcl
module "keyvault" {
  source = "git::https://dev.azure.com/org/project/_git/repo//modules/keyvault?ref=v1.0.0"
}
```

---

## Version Constraints

### Using Tags (Recommended)

```hcl
# Specific version
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=v1.2.3"
}

# Semantic versioning
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=v1.0.0"
}
```

### Using Branches

```hcl
# Main/master branch (latest)
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=main"
}

# Feature branch
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=feature/new-feature"
}

# Development branch
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=develop"
}
```

### Using Commit Hashes

```hcl
# Specific commit (most specific)
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=abc123def456789"
}
```

---

## Versioning Strategy

### Strategy 1: Semantic Versioning

```
v1.0.0 - Initial release
v1.0.1 - Bug fixes
v1.1.0 - New features (backward compatible)
v2.0.0 - Breaking changes
```

**Usage:**
```hcl
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=v1.1.0"
}
```

### Strategy 2: Environment-Based Tags

```
prod-v1.0.0
staging-v1.0.0
dev-latest
```

**Usage:**
```hcl
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=prod-v1.0.0"
}
```

### Strategy 3: Date-Based Versioning

```
2024-01-15
2024-01-15-v2
```

**Usage:**
```hcl
module "keyvault" {
  source = "git::https://github.com/org/modules.git//keyvault?ref=2024-01-15"
}
```

---

## Converting Local Modules to Git

### Step 1: Create Git Repository

```bash
# Initialize git in modules directory
cd modules/keyvault
git init
git add .
git commit -m "Initial commit: KeyVault module v1.0.0"
git tag v1.0.0

# Push to remote
git remote add origin https://github.com/org/terraform-modules.git
git push -u origin main
git push --tags
```

### Step 2: Update Root Module

```hcl
# Before (local)
module "keyvault" {
  source = "./modules/keyvault"
}

# After (Git)
module "keyvault" {
  source = "git::https://github.com/org/terraform-modules.git//modules/keyvault?ref=v1.0.0"
}
```

### Step 3: Initialize

```bash
terraform init
# Terraform will download module from Git
```

---

## Answers to Questions

### What are the benefits of using Git sources vs. local paths?

**Git Sources Benefits:**
1. **Version Control:** Pin specific versions
2. **Reusability:** Share modules across projects
3. **Collaboration:** Multiple teams can use same modules
4. **Stability:** Changes don't break existing deployments
5. **Auditability:** Track module changes over time
6. **Distribution:** Easy to share and distribute

**Local Path Benefits:**
1. **Simplicity:** No Git setup required
2. **Speed:** No network download
3. **Development:** Easy to modify during development
4. **Testing:** Quick iteration

### How do you handle module updates when using Git sources?

**Approach 1: Manual Updates**
```bash
# Update to new version
terraform init -upgrade
# Review changes
terraform plan
# Apply if acceptable
terraform apply
```

**Approach 2: Version Pinning Strategy**
```hcl
# Pin to specific version (production)
source = "git::...?ref=v1.0.0"

# Use latest from branch (development)
source = "git::...?ref=develop"
```

**Approach 3: Automated Updates**
```bash
# Script to check for updates
#!/bin/bash
CURRENT_VERSION="v1.0.0"
LATEST_VERSION=$(git ls-remote --tags origin | tail -1 | cut -d'/' -f3)
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Update available: $LATEST_VERSION"
fi
```

### What's the difference between `ref` and `tag` in Git sources?

**Answer:** In Terraform Git sources, `ref` is a generic parameter that can refer to:
- Tags: `?ref=v1.0.0`
- Branches: `?ref=main`
- Commits: `?ref=abc123`

There's no separate `tag` parameter - you use `ref` for everything. The `ref` parameter tells Git what to checkout.

---

## Best Practices

### 1. Pin Versions in Production
```hcl
# ✅ Good - specific version
source = "git::...?ref=v1.0.0"

# ❌ Bad - latest (unpredictable)
source = "git::...?ref=main"
```

### 2. Use Semantic Versioning
```
v1.0.0 - Major.Minor.Patch
```

### 3. Document Version Requirements
```hcl
# Add comment explaining version choice
module "keyvault" {
  # Using v1.0.0 for production stability
  # v1.1.0 available but not tested yet
  source = "git::...?ref=v1.0.0"
}
```

### 4. Test Updates Before Production
```hcl
# Development uses latest
module "keyvault" {
  source = "git::...?ref=develop"
}

# Production uses pinned version
module "keyvault" {
  source = "git::...?ref=v1.0.0"
}
```

### 5. Use Module Registry When Possible
```hcl
# Terraform Registry (if published)
module "keyvault" {
  source  = "hashicorp/keyvault/azurerm"
  version = "~> 1.0"
}
```

---

## Migration Example

### Before: Local Modules
```hcl
module "ServicePrincipal" {
  source = "./modules/ServicePrincipal"
}

module "keyvault" {
  source = "./modules/keyvault"
}

module "aks" {
  source = "./modules/aks"
}
```

### After: Git Modules
```hcl
module "ServicePrincipal" {
  source = "git::https://github.com/org/terraform-azure-modules.git//ServicePrincipal?ref=v1.0.0"
}

module "keyvault" {
  source = "git::https://github.com/org/terraform-azure-modules.git//keyvault?ref=v1.0.0"
}

module "aks" {
  source = "git::https://github.com/org/terraform-azure-modules.git//aks?ref=v1.0.0"
}
```

### Hybrid Approach
```hcl
# Local modules for development
module "ServicePrincipal" {
  source = var.use_local_modules ? "./modules/ServicePrincipal" : "git::...?ref=v1.0.0"
}
```

---

## Troubleshooting Git Sources

### Issue: Authentication Required
```bash
# Use SSH instead of HTTPS
source = "git::git@github.com:org/repo.git//module?ref=v1.0.0"

# Or use token in URL (not recommended for security)
source = "git::https://token@github.com/org/repo.git//module?ref=v1.0.0"
```

### Issue: Module Not Found
```bash
# Verify repository exists and is accessible
git ls-remote https://github.com/org/repo.git

# Check ref exists
git ls-remote https://github.com/org/repo.git refs/tags/v1.0.0
```

### Issue: Wrong Path
```hcl
# Correct: // indicates path in repo
source = "git::https://github.com/org/repo.git//modules/keyvault?ref=v1.0.0"

# Wrong: single / doesn't work
source = "git::https://github.com/org/repo.git/modules/keyvault?ref=v1.0.0"
```

---

## Summary

1. **Local paths** are good for development
2. **Git sources** are better for production and sharing
3. **Pin versions** using tags for stability
4. **Use semantic versioning** for clear versioning
5. **Test updates** before applying to production
6. **Document** version choices and update procedures

