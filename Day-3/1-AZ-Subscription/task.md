# Terraform Modules - Azure Subscription Infrastructure

This project demonstrates how to use Terraform modules to create reusable, maintainable infrastructure code. It provisions an Azure Service Principal, Key Vault, and Azure Kubernetes Service (AKS) cluster using a modular architecture.

## 📚 What are Terraform Modules?

Terraform modules are **containers for multiple resources** that are used together. Think of them as reusable building blocks that encapsulate:

- **Resources**: The actual infrastructure components (VMs, storage accounts, etc.)
- **Variables**: Inputs that customize the module's behavior
- **Outputs**: Values that other modules or the root module can use

### Why Use Modules?

1. **Reusability**: Write once, use many times
2. **Organization**: Group related resources together
3. **Abstraction**: Hide complexity behind a simple interface
4. **Maintainability**: Update in one place, changes propagate everywhere
5. **Testing**: Test modules independently

### Module Structure

A Terraform module is simply a directory containing `.tf` files:

```
modules/
├── module-name/
│   ├── main.tf      # Resources and data sources
│   ├── variables.tf # Input variables
│   └── output.tf    # Output values
```

---

## 🏗️ Project Structure

This project uses a **root module** (the main directory) that calls **child modules** (in the `modules/` directory):

```
1-AZ-Subscription/
├── main.tf              # Root module - calls child modules
├── variables.tf         # Root module variables
├── output.tf            # Root module outputs
├── provider.tf          # Provider configuration
└── modules/             # Child modules directory
    ├── ServicePrincipal/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    ├── keyvault/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    └── aks/
        ├── main.tf
        ├── variables.tf
        └── output.tf
```

---

## 🔍 Understanding the Modules

### Module 1: ServicePrincipal

**Purpose:** Creates an Azure AD Service Principal (application identity) for authentication.

**Location:** `modules/ServicePrincipal/`

**What it creates:**
- Azure AD Application
- Service Principal
- Service Principal Password (client secret)

**Inputs (`variables.tf`):**
- `service_principal_name` - Name for the service principal

**Outputs (`output.tf`):**
- `client_id` - Application ID (used for authentication)
- `client_secret` - Password/secret (sensitive)
- `service_principal_object_id` - Object ID (used for role assignments)
- `service_principal_tenant_id` - Tenant ID

**Why it's a module:** This is reusable - you might need service principals for different purposes (AKS, automation, etc.).

---

### Module 2: KeyVault

**Purpose:** Creates an Azure Key Vault to securely store secrets.

**Location:** `modules/keyvault/`

**What it creates:**
- Azure Key Vault with RBAC authorization
- Premium SKU with soft delete enabled

**Inputs (`variables.tf`):**
- `keyvault_name` - Name of the key vault
- `location` - Azure region
- `resource_group_name` - Resource group name
- `service_principal_name` - Name (for reference)
- `service_principal_object_id` - Object ID (for access policies)
- `service_principal_tenant_id` - Tenant ID

**Outputs (`output.tf`):**
- `keyvault_id` - Key Vault resource ID

**Why it's a module:** Key Vaults are often created with similar configurations across environments.

---

### Module 3: AKS (Azure Kubernetes Service)

**Purpose:** Creates a managed Kubernetes cluster in Azure.

**Location:** `modules/aks/`

**What it creates:**
- Azure Kubernetes Service cluster
- Default node pool with auto-scaling (1-3 nodes)
- Network profile with Azure CNI
- Linux profile with SSH access

**Inputs (`variables.tf`):**
- `location` - Azure region
- `resource_group_name` - Resource group name
- `service_principal_name` - Name (for reference)
- `client_id` - Service principal client ID
- `client_secret` - Service principal secret (sensitive)
- `ssh_public_key` - Path to SSH public key (default: `~/.ssh/id_rsa.pub`)

**Outputs (`output.tf`):**
- `config` - Kubernetes configuration (kubeconfig) for cluster access

**Why it's a module:** AKS clusters have complex configurations that benefit from encapsulation.

---

## 🔗 How Modules Connect

The root `main.tf` orchestrates all modules:

```hcl
# 1. Create Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

# 2. Create Service Principal (Module)
module "ServicePrincipal" {
  source                 = "./modules/ServicePrincipal"
  service_principal_name = var.service_principal_name
  depends_on = [azurerm_resource_group.rg1]
}

# 3. Assign Role to Service Principal
resource "azurerm_role_assignment" "rolespn" {
  scope                = "/subscriptions/${var.SUB_ID}"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id
  depends_on = [module.ServicePrincipal]
}

# 4. Create Key Vault (Module)
module "keyvault" {
  source                      = "./modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id
  depends_on = [module.ServicePrincipal]
}

# 5. Store Service Principal Secret in Key Vault
resource "azurerm_key_vault_secret" "example" {
  name         = module.ServicePrincipal.client_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id
  depends_on = [module.keyvault]
}

# 6. Create AKS Cluster (Module)
module "aks" {
  source                 = "./modules/aks/"
  service_principal_name = var.service_principal_name
  client_id              = module.ServicePrincipal.client_id
  client_secret          = module.ServicePrincipal.client_secret
  location               = var.location
  resource_group_name    = var.rgname
  depends_on = [module.ServicePrincipal]
}

# 7. Save Kubernetes Config to File
resource "local_file" "kubeconfig" {
  depends_on = [module.aks]
  filename   = "./kubeconfig"
  content    = module.aks.config
}
```

### Dependency Flow

```
Resource Group
    ↓
Service Principal Module
    ↓
    ├──→ Role Assignment (uses SP object_id)
    ├──→ Key Vault Module (uses SP object_id, tenant_id)
    │       ↓
    │   Key Vault Secret (uses SP client_id, client_secret, KV id)
    └──→ AKS Module (uses SP client_id, client_secret)
            ↓
        Kubeconfig File (uses AKS config)
```

---

## 🚀 How to Build This Infrastructure

### Prerequisites

1. **Azure CLI** installed and configured
   ```bash
   az login
   az account show  # Get your subscription ID
   ```

2. **Terraform** installed (version >= 1.9.0)
   ```bash
   terraform version
   ```

3. **Azure AD permissions** (to create service principals)
   - Global Administrator or Application Administrator role

4. **SSH Key** (for AKS)
   ```bash
   # Generate if you don't have one
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

### Step 1: Configure Variables

Create a `terraform.tfvars` file in the root directory:

```hcl
rgname                  = "my-resource-group"
location                = "canadacentral"
service_principal_name  = "my-aks-sp"
keyvault_name          = "my-keyvault-unique-name"  # Must be globally unique
SUB_ID                 = "your-subscription-id-here"
```

**Important Notes:**
- `keyvault_name` must be globally unique (3-24 characters, alphanumeric and hyphens)
- `SUB_ID` is your Azure subscription ID (get it with `az account show --query id -o tsv`)

### Step 2: Initialize Terraform

```bash
terraform init
```

This will:
- Download required providers (azurerm, azuread)
- Initialize the backend (if configured)
- **Download/validate child modules** from `./modules/` directory

### Step 3: Review the Plan

```bash
terraform plan
```

This shows you:
- What resources will be created
- Module calls and their inputs/outputs
- Dependencies between resources

**Expected Output:**
- Resource Group: 1 resource
- Service Principal Module: 3 resources (app, SP, password)
- Role Assignment: 1 resource
- Key Vault Module: 1 resource
- Key Vault Secret: 1 resource
- AKS Module: 1 resource (cluster)
- Local File: 1 resource (kubeconfig)

### Step 4: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted, or use:
```bash
terraform apply -auto-approve
```

**What Happens:**
1. Resource group is created
2. Service Principal module creates the SP and credentials
3. Role assignment gives SP Contributor access
4. Key Vault module creates the vault
5. Service Principal secret is stored in Key Vault
6. AKS module creates the Kubernetes cluster (this takes 10-15 minutes)
7. Kubeconfig file is saved locally

### Step 5: Verify Resources

**Check Azure Portal:**
- Resource Group → Should contain Key Vault and AKS cluster
- Azure AD → App registrations → Should see your service principal
- Key Vault → Should contain the client secret

**Check Local Files:**
```bash
ls -la kubeconfig  # Should exist
```

**Connect to AKS:**
```bash
export KUBECONFIG=./kubeconfig
kubectl get nodes
```

---

## 🔧 Understanding Module Syntax

### Calling a Module

```hcl
module "module_name" {
  source = "./modules/module_directory"
  
  # Pass input variables
  variable_name = value
  
  # Reference other resources/modules
  another_variable = module.other_module.output_value
  
  # Explicit dependencies
  depends_on = [resource.name]
}
```

### Accessing Module Outputs

```hcl
# In root module or other modules
module.module_name.output_name

# Example:
module.ServicePrincipal.client_id
module.keyvault.keyvault_id
```

### Module Source Types

1. **Local Path** (this project):
   ```hcl
   source = "./modules/keyvault"
   ```

2. **Git Repository**:
   ```hcl
   source = "git::https://github.com/org/repo.git//modules/keyvault"
   ```

3. **Terraform Registry**:
   ```hcl
   source = "hashicorp/consul/aws"
   ```

4. **HTTP URL**:
   ```hcl
   source = "https://example.com/module.zip"
   ```

---

## 📊 Module Benefits in This Project

### 1. **Separation of Concerns**
- Each module handles one specific component
- Changes to AKS don't affect Key Vault module

### 2. **Reusability**
- Service Principal module can be reused for other projects
- Key Vault module can be used in different environments

### 3. **Maintainability**
- Update AKS configuration in one place (`modules/aks/main.tf`)
- All AKS clusters using this module get the update

### 4. **Testing**
- Test each module independently
- Validate inputs/outputs before integration

### 5. **Readability**
- Root `main.tf` is clean and shows the big picture
- Complex details are hidden in modules

---

## 🎯 Key Concepts

### Module Variables vs Root Variables

**Root Variables** (`variables.tf` in root):
- Define what the user needs to provide
- High-level configuration

**Module Variables** (`variables.tf` in module):
- Define what the module needs
- Specific to the module's functionality

### Module Outputs

Modules expose outputs that:
- Other modules can consume
- Root module can use
- Can be displayed with `terraform output`

### Dependencies

Modules can depend on:
- Other modules: `depends_on = [module.name]`
- Resources: `depends_on = [resource.name]`
- Implicit dependencies via variable references

---

## 🐛 Troubleshooting

### Issue: Module not found
**Error:** `Error: Module not found`
**Solution:** 
- Check `source` path is correct
- Run `terraform init` to download modules
- Verify module directory exists

### Issue: Variable not set
**Error:** `Error: Missing required variable`
**Solution:**
- Check `terraform.tfvars` has all required variables
- Verify variable names match exactly (case-sensitive)
- Check module's `variables.tf` for required variables

### Issue: Output not available
**Error:** `Error: Reference to undeclared output`
**Solution:**
- Verify output exists in module's `output.tf`
- Check output name matches exactly
- Ensure module has been applied (outputs created after apply)

### Issue: Circular dependency
**Error:** `Error: Cycle detected`
**Solution:**
- Review `depends_on` statements
- Check for circular references between modules
- Break the cycle by restructuring dependencies

---

## 📝 Best Practices

1. **One Module = One Purpose**
   - Each module should have a single, clear responsibility

2. **Document Variables and Outputs**
   - Add descriptions to all variables and outputs
   - Helps others understand the module

3. **Use Explicit Dependencies**
   - Use `depends_on` when order matters
   - Don't rely only on implicit dependencies

4. **Version Modules**
   - Tag modules in Git for versioning
   - Use version constraints in production

5. **Test Modules Independently**
   - Create test configurations for each module
   - Validate inputs/outputs before integration

---

## 🔄 Modifying Modules

### Adding a New Module

1. Create directory: `modules/new-module/`
2. Add `main.tf`, `variables.tf`, `output.tf`
3. Call module in root `main.tf`:
   ```hcl
   module "new_module" {
     source = "./modules/new-module"
     # ... variables
   }
   ```

### Updating an Existing Module

1. Modify module files in `modules/module-name/`
2. Run `terraform init -upgrade` to refresh modules
3. Run `terraform plan` to see changes
4. Apply changes with `terraform apply`

---

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note:** This will:
- Delete the AKS cluster (takes several minutes)
- Delete Key Vault (may have retention period)
- Delete Service Principal
- Delete Resource Group and all resources

---

## 📚 Additional Resources

- [Terraform Modules Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure AD Provider Documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)

---

## 🎓 Learning Objectives Achieved

After working with this project, you should understand:

- ✅ What Terraform modules are and why to use them
- ✅ How to structure a module (main.tf, variables.tf, output.tf)
- ✅ How to call modules from root configuration
- ✅ How to pass data between modules using outputs
- ✅ How to manage dependencies between modules
- ✅ How modules improve code organization and reusability

---

## 📋 Quick Reference

**Initialize:**
```bash
terraform init
```

**Plan:**
```bash
terraform plan
```

**Apply:**
```bash
terraform apply
```

**View Outputs:**
```bash
terraform output
```

**Destroy:**
```bash
terraform destroy
```

**Format Code:**
```bash
terraform fmt -recursive
```

**Validate:**
```bash
terraform validate
```

