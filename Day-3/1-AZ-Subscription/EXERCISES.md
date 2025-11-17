# Terraform Modules - Exercises

This exercise guide provides hands-on challenges for working with Terraform modules. Complete these exercises to master module creation, usage, and best practices.

## 📚 Prerequisites

- Understanding of Terraform resources and variables
- Basic knowledge of Azure resources
- Access to Azure subscription
- Terraform installed and configured
- Completed the README.md walkthrough (recommended)

---

## 🎯 Exercise 1: Understanding Module Structure

**Challenge:** Analyze the existing modules and document their structure.

**Tasks:**
1. Examine each module in the `modules/` directory
2. For each module, identify:
   - What resources it creates
   - What variables it accepts
   - What outputs it provides
   - What dependencies it has

**Questions to Answer:**
- What is the purpose of the ServicePrincipal module?
- How many resources does the KeyVault module create?
- What outputs from ServicePrincipal module are used by other modules?
- Why does the AKS module need the Service Principal's client_id and client_secret?

**Deliverables:**
- Create a document mapping module inputs to outputs
- Draw a dependency diagram showing how modules connect
- List all module outputs and where they're consumed

**Success Criteria:**
- [ ] Can explain what each module does
- [ ] Understand module dependencies
- [ ] Know which outputs are used where

---

## 🎯 Exercise 2: Create a New Storage Account Module

**Challenge:** Create a new module for Azure Storage Account.

**Requirements:**
1. Create a new module directory: `modules/storage-account/`
2. Create the standard module files:
   - `main.tf` - Storage account resource
   - `variables.tf` - Input variables
   - `output.tf` - Output values

**Module Specifications:**
- **Resource:** `azurerm_storage_account`
- **Required Variables:**
  - `storage_account_name` (string) - Name of storage account
  - `resource_group_name` (string) - Resource group name
  - `location` (string) - Azure region
- **Optional Variables:**
  - `account_tier` (string, default: "Standard")
  - `account_replication_type` (string, default: "LRS")
  - `tags` (map(string), default: {})
- **Outputs:**
  - `storage_account_id` - Storage account resource ID
  - `primary_access_key` - Primary access key (sensitive)
  - `primary_blob_endpoint` - Primary blob endpoint URL

**Tasks:**
1. Create the module structure
2. Implement the storage account resource
3. Define all variables with descriptions
4. Create outputs for the required values
5. Call the module from root `main.tf`
6. Test with `terraform plan`

**Questions to Answer:**
- Why should `primary_access_key` be marked as sensitive in outputs?
- What happens if you don't provide optional variables?
- How do you reference the storage account from other resources?

**Success Criteria:**
- [ ] Module created with proper structure
- [ ] All variables defined with types and descriptions
- [ ] Storage account resource created correctly
- [ ] Outputs work and can be referenced
- [ ] Module called successfully from root

---

## 🎯 Exercise 3: Modify Existing Module - Add Features to KeyVault

**Challenge:** Enhance the KeyVault module with additional features.

**Requirements:**
1. Add a variable for `enabled_for_deployment` (bool, default: false)
2. Add a variable for `enabled_for_template_deployment` (bool, default: false)
3. Add a variable for `enabled_for_disk_encryption` (bool, default: true)
4. Add a variable for `soft_delete_retention_days` (number, default: 7)
5. Update the KeyVault resource to use these variables
6. Add an output for `keyvault_uri` (the vault URI)

**Tasks:**
1. Modify `modules/keyvault/variables.tf` to add new variables
2. Update `modules/keyvault/main.tf` to use the new variables
3. Add the new output to `modules/keyvault/output.tf`
4. Update root `main.tf` if needed to pass new variables
5. Run `terraform init -upgrade` to refresh modules
6. Test with `terraform plan`

**Questions to Answer:**
- Why use variables with defaults instead of hardcoding values?
- What's the benefit of making these configurable?
- How does changing a module affect existing infrastructure?

**Success Criteria:**
- [ ] New variables added with proper types and defaults
- [ ] KeyVault resource uses new variables
- [ ] New output created and accessible
- [ ] Plan shows expected changes
- [ ] No breaking changes to existing functionality

---

## 🎯 Exercise 4: Module Dependencies and Data Flow

**Challenge:** Understand and modify module dependencies.

**Current Setup:**
- ServicePrincipal module creates SP
- KeyVault module uses SP object_id and tenant_id
- AKS module uses SP client_id and client_secret

**Tasks:**
1. **Trace the data flow:**
   - Document how ServicePrincipal outputs flow to other modules
   - Identify all places where module outputs are consumed
   - Create a visual diagram showing the flow

2. **Add a new dependency:**
   - Modify the Storage Account module (from Exercise 2) to accept a Key Vault ID
   - Store the storage account primary access key in Key Vault as a secret
   - Ensure proper dependency ordering

3. **Test dependency behavior:**
   - Remove a `depends_on` statement and see what happens
   - Add explicit dependencies where needed
   - Verify Terraform creates resources in correct order

**Questions to Answer:**
- What's the difference between implicit and explicit dependencies?
- When should you use `depends_on` vs. variable references?
- What happens if you remove a dependency that's actually needed?

**Success Criteria:**
- [ ] Can trace all module output flows
- [ ] Understand dependency relationships
- [ ] Successfully added new dependency
- [ ] Resources created in correct order

---

## 🎯 Exercise 5: Module Outputs and Root Module Usage

**Challenge:** Use module outputs effectively in the root module.

**Current Situation:**
The root module outputs some values but could expose more useful information.

**Tasks:**
1. **Review root `output.tf`:**
   - What outputs are currently exposed?
   - What additional outputs would be useful?

2. **Add new root outputs:**
   - Key Vault URI (from KeyVault module)
   - AKS cluster name (from AKS module)
   - Storage account name (from Storage Account module, if created)
   - Service Principal tenant ID

3. **Create a comprehensive output file:**
   - Group outputs logically
   - Add descriptions to all outputs
   - Mark sensitive outputs appropriately

4. **Test outputs:**
   ```bash
   terraform output
   terraform output -json
   terraform output key_vault_uri
   ```

**Questions to Answer:**
- Why expose outputs from the root module instead of accessing modules directly?
- When should outputs be marked as sensitive?
- How can outputs be used by other tools or scripts?

**Success Criteria:**
- [ ] Root outputs include all important values
- [ ] Outputs are well-organized and documented
- [ ] Sensitive outputs properly marked
- [ ] Can access outputs via CLI

---

## 🎯 Exercise 6: Conditional Module Usage

**Challenge:** Make module usage conditional based on variables.

**Requirements:**
1. Add a variable `create_storage_account` (bool, default: false) to root `variables.tf`
2. Conditionally create the Storage Account module based on this variable
3. Ensure other resources that depend on storage account handle the conditional

**Implementation Hint:**
```hcl
module "storage_account" {
  count = var.create_storage_account ? 1 : 0
  source = "./modules/storage-account"
  # ... variables
}
```

**Tasks:**
1. Add the conditional variable
2. Modify module call to use `count`
3. Update any references to use `module.storage_account[0]` syntax
4. Test with both `true` and `false` values
5. Verify plan shows correct resources

**Questions to Answer:**
- What's the difference between `count` and `for_each` for modules?
- How do you reference a module when using `count`?
- When would you want conditional module creation?

**Bonus Challenge:**
- Use `for_each` instead of `count` to create multiple storage accounts
- Create a map variable with storage account configurations

**Success Criteria:**
- [ ] Module created conditionally based on variable
- [ ] References work correctly with conditional syntax
- [ ] Plan shows correct behavior for both cases
- [ ] Understand conditional module patterns

---

## 🎯 Exercise 7: Module Versioning and Source Control

**Challenge:** Understand module source types and versioning.

**Tasks:**
1. **Current Setup Analysis:**
   - What source type is currently used? (Local path)
   - Document the current module source syntax

2. **Convert to Git Source:**
   - If modules were in a Git repo, how would you reference them?
   - Write example source paths for:
     - GitHub public repo
     - GitHub private repo
     - GitLab repo
     - Azure DevOps repo

3. **Version Constraints:**
   - Research how to pin module versions in Git
   - Write examples of version constraints:
     - Specific version tag
     - Branch reference
     - Commit hash

**Example Formats:**
```hcl
# Git source examples
source = "git::https://github.com/org/repo.git//modules/keyvault?ref=v1.0.0"
source = "git::https://github.com/org/repo.git//modules/keyvault?ref=main"
source = "git::https://github.com/org/repo.git//modules/keyvault?ref=abc123"
```

**Questions to Answer:**
- What are the benefits of using Git sources vs. local paths?
- How do you handle module updates when using Git sources?
- What's the difference between `ref` and `tag` in Git sources?

**Success Criteria:**
- [ ] Understand different source types
- [ ] Can write Git source syntax
- [ ] Know how to version modules
- [ ] Understand version pinning strategies

---

## 🎯 Exercise 8: Module Testing and Validation

**Challenge:** Test and validate module functionality.

**Tasks:**
1. **Syntax Validation:**
   ```bash
   cd modules/keyvault
   terraform init
   terraform validate
   terraform fmt -check
   ```

2. **Plan Testing:**
   - Create a test `terraform.tfvars` file for the KeyVault module
   - Run `terraform plan` to verify it works
   - Check for any errors or warnings

3. **Output Testing:**
   - Verify all outputs are accessible
   - Test output formatting
   - Check sensitive outputs are marked correctly

4. **Dependency Testing:**
   - Test module with missing required variables
   - Test module with invalid variable values
   - Verify error messages are helpful

**Questions to Answer:**
- What does `terraform validate` check?
- Why run `terraform fmt` before committing?
- How do you test a module in isolation?

**Success Criteria:**
- [ ] Module validates successfully
- [ ] Plan works with test variables
- [ ] Outputs accessible and correct
- [ ] Error handling works properly

---

## 🎯 Exercise 9: Refactor - Extract Common Patterns

**Challenge:** Identify and extract common patterns into reusable modules.

**Observation:**
Multiple modules might share common patterns like:
- Tags
- Location/resource group references
- Naming conventions

**Tasks:**
1. **Analyze Common Patterns:**
   - Review all modules for repeated code
   - Identify common variable patterns
   - Find repeated resource configurations

2. **Create a Common Module:**
   - Create `modules/common/` module
   - Extract common tag logic
   - Create standardized naming functions
   - Provide common outputs

3. **Refactor Existing Modules:**
   - Update modules to use common patterns
   - Reduce duplication
   - Maintain functionality

**Example:**
```hcl
# modules/common/locals.tf
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}
```

**Questions to Answer:**
- What patterns are repeated across modules?
- How can you reduce code duplication?
- What's the balance between abstraction and simplicity?

**Success Criteria:**
- [ ] Common patterns identified
- [ ] Common module created
- [ ] Existing modules refactored
- [ ] Functionality maintained

---

## 🎯 Exercise 10: Troubleshooting Module Issues

**Challenge:** Diagnose and fix common module problems.

**Scenarios to Fix:**

### Scenario 1: Module Not Found
**Error:** `Error: Module not found`
**Task:** Diagnose and fix the issue

### Scenario 2: Variable Not Set
**Error:** `Error: Missing required variable "location"`
**Task:** Identify missing variable and fix

### Scenario 3: Output Not Available
**Error:** `Error: Reference to undeclared output value`
**Task:** Fix the output reference

### Scenario 4: Circular Dependency
**Error:** `Error: Cycle detected`
**Task:** Identify and break the cycle

### Scenario 5: Module Version Mismatch
**Error:** Module expects different variable structure
**Task:** Update module call to match new structure

**Tasks:**
1. For each scenario, create a test case that reproduces the error
2. Document the error message
3. Identify the root cause
4. Fix the issue
5. Document the solution

**Questions to Answer:**
- How do you debug module issues?
- What tools help troubleshoot module problems?
- How do you prevent these issues?

**Success Criteria:**
- [ ] Can reproduce each error scenario
- [ ] Understand root causes
- [ ] Successfully fixed all issues
- [ ] Documented solutions

---

## 🎯 Exercise 11: Advanced - Module Composition

**Challenge:** Create a composite module that uses other modules.

**Requirements:**
Create a new module `modules/complete-infrastructure/` that:
- Uses the ServicePrincipal module
- Uses the KeyVault module
- Uses the AKS module
- Orchestrates their creation and dependencies
- Provides a single interface for creating all infrastructure

**Tasks:**
1. Create the composite module structure
2. Call child modules within the composite module
3. Pass variables through appropriately
4. Aggregate outputs from child modules
5. Handle dependencies between child modules
6. Test the composite module

**Module Interface:**
```hcl
# Inputs
- environment_name
- location
- subscription_id
- create_aks (bool, default: true)
- create_keyvault (bool, default: true)

# Outputs
- service_principal_client_id
- key_vault_id
- aks_cluster_name (if created)
- kubeconfig (if AKS created)
```

**Questions to Answer:**
- What's the benefit of composite modules?
- How do you handle optional child modules?
- When is module composition appropriate?

**Success Criteria:**
- [ ] Composite module created
- [ ] Child modules called correctly
- [ ] Dependencies handled
- [ ] Outputs aggregated properly
- [ ] Module works end-to-end

---

## 🎯 Exercise 12: Documentation and Best Practices

**Challenge:** Document modules following best practices.

**Requirements:**
1. **Add README to Each Module:**
   - Purpose and description
   - Usage examples
   - Input variables table
   - Outputs table
   - Dependencies
   - Examples

2. **Improve Variable Descriptions:**
   - Add descriptions to all variables
   - Include examples where helpful
   - Document default values

3. **Add Output Descriptions:**
   - Describe what each output provides
   - Include usage examples
   - Mark sensitive outputs

4. **Create Usage Examples:**
   - Basic usage
   - Advanced usage with all options
   - Common patterns

**Example Module README Structure:**
```markdown
# Module Name

## Description
Brief description of what this module does.

## Usage
```hcl
module "example" {
  source = "./modules/example"
  # variables
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| var1 | Description | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| output1 | Description |

## Dependencies
- Resource Group must exist
- Service Principal must exist
```

**Success Criteria:**
- [ ] Each module has README
- [ ] All variables documented
- [ ] All outputs documented
- [ ] Usage examples provided
- [ ] Documentation is clear and helpful

---

## 📝 Notes Section

Use this section to document your findings and answers:

### Exercise 1 - Module Structure:
- 
- 

### Exercise 2 - Storage Account Module:
- 
- 

### Exercise 3 - KeyVault Enhancements:
- 
- 

### Exercise 4 - Dependencies:
- 
- 

### Exercise 5 - Outputs:
- 
- 

### Exercise 6 - Conditional Modules:
- 
- 

### Exercise 7 - Versioning:
- 
- 

### Exercise 8 - Testing:
- 
- 

### Exercise 9 - Refactoring:
- 
- 

### Exercise 10 - Troubleshooting:
- 
- 

### Exercise 11 - Composition:
- 
- 

### Exercise 12 - Documentation:
- 
- 

### Key Learnings:
1. 
2. 
3. 

---

## 🏆 Completion Checklist

- [ ] Exercise 1: Module structure analyzed
- [ ] Exercise 2: Storage Account module created
- [ ] Exercise 3: KeyVault module enhanced
- [ ] Exercise 4: Dependencies understood
- [ ] Exercise 5: Root outputs improved
- [ ] Exercise 6: Conditional modules implemented
- [ ] Exercise 7: Versioning concepts learned
- [ ] Exercise 8: Module testing completed
- [ ] Exercise 9: Refactoring done
- [ ] Exercise 10: Troubleshooting scenarios fixed
- [ ] Exercise 11: Composite module created
- [ ] Exercise 12: Documentation completed

---

## 💡 Tips for Success

1. **Start Simple:** Begin with Exercise 1 and 2 to understand basics
2. **Test Incrementally:** Test each change before moving to the next
3. **Use terraform plan:** Always plan before applying
4. **Read Error Messages:** Terraform provides helpful error details
5. **Experiment:** Try breaking things (safely!) to understand behavior
6. **Document:** Write down what you learn as you go

---

## 🚀 Ready to Start?

Begin with Exercise 1 and work through them sequentially. Each exercise builds on concepts from previous ones. Good luck!

**Remember:** These are challenges - figure it out yourself! Use Terraform documentation, error messages, and experimentation to solve them.

