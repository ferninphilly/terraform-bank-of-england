# Azure Policy and Governance - Challenge Exercises

This exercise guide provides hands-on challenges for working with Azure Policies and Governance using Terraform. Complete these exercises to master policy creation, assignment, and testing.

## 📚 Prerequisites

- Understanding of Terraform resources and variables
- Basic knowledge of Azure resources
- Access to Azure subscription with Policy Contributor permissions
- Terraform installed and configured
- Completed the task.md walkthrough (recommended)

---

## 🎯 Exercise 1: Understanding Policy Structure

**Challenge:** Analyze existing policies and document their structure.

**Tasks:**
1. Examine each policy definition in `main.tf`
2. For each policy, identify:
   - Policy name and display name
   - Policy type and mode
   - The field being checked
   - The condition (operator and values)
   - The effect (what happens when non-compliant)
3. Document the policy rule logic in plain English
4. Identify which variables are used in each policy

**Questions to Answer:**
- What's the difference between policy type "Custom" and "BuiltIn"?
- What does policy mode "All" mean?
- How does the `anyOf` operator work in the tagging policy?
- What's the difference between `in` and `notIn` operators?

**Deliverables:**
- Policy analysis document
- Flowchart showing policy evaluation logic
- Variable mapping document

**Success Criteria:**
- [ ] Can explain each policy's purpose
- [ ] Understand policy rule structure
- [ ] Know how variables are used
- [ ] Understand policy effects

---

## 🎯 Exercise 2: Create a New Policy - Storage Account SKU Restriction

**Challenge:** Create a new policy that restricts storage account SKUs.

**Requirements:**
1. Create a new policy definition that only allows:
   - Standard_LRS (Locally Redundant Storage)
   - Standard_GRS (Geo-Redundant Storage)
2. Add a variable for allowed SKUs
3. Assign the policy to the subscription
4. Test with compliant and non-compliant storage accounts

**Policy Specifications:**
- **Name:** `storage-account-sku`
- **Display Name:** "Allowed Storage Account SKU Policy"
- **Field to Check:** `Microsoft.Storage/storageAccounts/sku.name`
- **Effect:** `deny`
- **Allowed SKUs:** Standard_LRS, Standard_GRS

**Tasks:**
1. Add variable to `variables.tf`
2. Create policy definition in `main.tf`
3. Create policy assignment
4. Test with `terraform plan`

**Questions to Answer:**
- What field path is used for storage account SKU?
- How do you check if a value is in a list?
- What happens if you try to create a Premium storage account?

**Success Criteria:**
- [ ] Policy definition created
- [ ] Policy assigned to subscription
- [ ] Compliant storage accounts allowed
- [ ] Non-compliant storage accounts blocked

---

## 🎯 Exercise 3: Modify Existing Policy - Add More Allowed Locations

**Challenge:** Enhance the location policy to support more regions.

**Requirements:**
1. Add more allowed locations to the policy:
   - Current: eastus, westus
   - Add: canadacentral, westeurope, uksouth
2. Update the policy rule to handle dynamic number of locations
3. Use a loop or function to make it scalable
4. Test with new locations

**Tasks:**
1. Update `variables.tf` to include more locations
2. Modify policy rule to use all locations dynamically
3. Update policy assignment if needed
4. Test with `terraform plan` and `apply`

**Implementation Hint:**
```hcl
# Instead of hardcoding locations, use join() or a loop
notIn = var.location  # Use entire list
```

**Questions to Answer:**
- How do you make a policy rule work with variable-length lists?
- What's the best way to maintain a list of allowed locations?
- How do you update an existing policy definition?

**Success Criteria:**
- [ ] Policy supports multiple locations
- [ ] Policy rule is dynamic
- [ ] New locations work correctly
- [ ] Old locations still work

---

## 🎯 Exercise 4: Create Audit-Only Policy

**Challenge:** Create a policy that audits instead of denies.

**Requirements:**
1. Create a new policy that audits (logs but doesn't block):
   - Policy: Check if resources have an "environment" tag
   - Effect: `audit` instead of `deny`
2. Assign the policy
3. Create a resource without the tag
4. Verify it's created but marked as non-compliant

**Policy Specifications:**
- **Name:** `audit-environment-tag`
- **Display Name:** "Audit Environment Tag Policy"
- **Field:** `tags[environment]`
- **Effect:** `audit`
- **Condition:** Tag doesn't exist

**Tasks:**
1. Create policy definition with `audit` effect
2. Create policy assignment
3. Create a resource without environment tag
4. Check compliance status in Azure Portal

**Questions to Answer:**
- What's the difference between `deny` and `audit`?
- When would you use `audit` instead of `deny`?
- How do you view audit results?

**Success Criteria:**
- [ ] Audit policy created
- [ ] Resources created even without tag
- [ ] Non-compliance logged
- [ ] Can view compliance status

---

## 🎯 Exercise 5: Policy with Multiple Conditions

**Challenge:** Create a complex policy with multiple conditions.

**Requirements:**
1. Create a policy that enforces:
   - Resource must have "department" tag
   - Resource must have "project" tag
   - Resource must have "costcenter" tag
   - All three tags must exist (use `allOf`)
2. Test with resources missing different combinations of tags

**Policy Specifications:**
- **Name:** `required-tags-all`
- **Display Name:** "All Required Tags Policy"
- **Effect:** `deny`
- **Logic:** All tags must exist (allOf)

**Tasks:**
1. Create policy with `allOf` operator
2. Add costcenter to variables
3. Create policy assignment
4. Test various tag combinations

**Questions to Answer:**
- What's the difference between `anyOf` and `allOf`?
- How do you structure multiple conditions?
- What happens if one tag is missing?

**Success Criteria:**
- [ ] Policy checks all three tags
- [ ] Resources blocked if any tag missing
- [ ] Resources allowed if all tags present
- [ ] Understand allOf vs anyOf

---

## 🎯 Exercise 6: Resource Group Level Policy Assignment

**Challenge:** Assign a policy to a resource group instead of subscription.

**Requirements:**
1. Create a policy that only applies to a specific resource group
2. Use `azurerm_resource_group_policy_assignment` instead of subscription assignment
3. Test that policy only affects that resource group
4. Verify other resource groups are not affected

**Tasks:**
1. Create a test resource group
2. Create policy assignment scoped to resource group
3. Test policy enforcement
4. Verify subscription-level resources aren't affected

**Questions to Answer:**
- What's the difference between subscription and resource group assignments?
- When would you use resource group level policies?
- How do you scope policies to specific resources?

**Success Criteria:**
- [ ] Policy assigned to resource group
- [ ] Policy only affects that resource group
- [ ] Other resource groups unaffected
- [ ] Understand policy scoping

---

## 🎯 Exercise 7: Policy with Modify Effect

**Challenge:** Create a policy that automatically adds missing tags.

**Requirements:**
1. Create a policy with `modify` effect
2. Policy should automatically add "ManagedBy = Terraform" tag
3. Test by creating a resource without the tag
4. Verify tag is added automatically

**Policy Specifications:**
- **Name:** `auto-add-managedby-tag`
- **Display Name:** "Auto Add ManagedBy Tag"
- **Effect:** `modify`
- **Action:** Add tag `ManagedBy = Terraform`

**Tasks:**
1. Research modify effect syntax
2. Create policy definition with modify effect
3. Create policy assignment
4. Test with resource creation

**Questions to Answer:**
- How does the `modify` effect work?
- What's the syntax for modify operations?
- When would you use modify vs deny?

**Success Criteria:**
- [ ] Modify policy created
- [ ] Tag added automatically
- [ ] Resource created successfully
- [ ] Tag present on resource

---

## 🎯 Exercise 8: Policy Exemption

**Challenge:** Create a policy exemption for special cases.

**Requirements:**
1. Create a policy exemption for a specific resource group
2. Exempt the resource group from location policy
3. Verify exempted resource group can use any location
4. Document exemption reason

**Tasks:**
1. Create a resource group for exemption
2. Create policy exemption resource
3. Test creating resource in non-compliant location
4. Verify exemption works

**Questions to Answer:**
- When would you use policy exemptions?
- How do exemptions work?
- What information should be documented for exemptions?

**Success Criteria:**
- [ ] Policy exemption created
- [ ] Exempted resource group can use any location
- [ ] Exemption documented
- [ ] Understand exemption use cases

---

## 🎯 Exercise 9: Policy Set (Initiative)

**Challenge:** Create a policy set that groups multiple policies.

**Requirements:**
1. Create a policy set (initiative) that includes:
   - Location policy
   - Tagging policy
   - VM size policy
2. Assign the policy set instead of individual policies
3. Test that all policies in the set are enforced

**Tasks:**
1. Research policy set syntax
2. Create policy set definition
3. Add policy definitions to set
4. Create policy set assignment
5. Test enforcement

**Questions to Answer:**
- What's the benefit of policy sets?
- How do you add policies to a set?
- Can you mix built-in and custom policies in a set?

**Success Criteria:**
- [ ] Policy set created
- [ ] All policies included in set
- [ ] Policy set assigned
- [ ] All policies enforced

---

## 🎯 Exercise 10: Compliance Monitoring

**Challenge:** Set up compliance monitoring and reporting.

**Requirements:**
1. Create resources with different compliance states
2. Check compliance status using Terraform data sources
3. Create outputs showing compliance information
4. Document how to monitor compliance

**Tasks:**
1. Research compliance data sources
2. Create data sources for policy compliance
3. Add outputs for compliance status
4. Test compliance checking

**Questions to Answer:**
- How do you check policy compliance programmatically?
- What data sources are available for compliance?
- How often does compliance status update?

**Success Criteria:**
- [ ] Compliance data sources created
- [ ] Compliance outputs working
- [ ] Can query compliance status
- [ ] Understand monitoring approach

---

## 🎯 Exercise 11: Advanced Policy - Resource Naming Convention

**Challenge:** Create a policy that enforces naming conventions.

**Requirements:**
1. Create a policy that enforces resource names must:
   - Start with environment prefix (dev-, staging-, prod-)
   - Contain resource type abbreviation
   - End with unique identifier
2. Use `like` operator for pattern matching
3. Test with compliant and non-compliant names

**Policy Specifications:**
- **Name:** `resource-naming-convention`
- **Display Name:** "Resource Naming Convention Policy"
- **Pattern:** `dev-*-rg` or `prod-*-rg` for resource groups
- **Effect:** `deny`

**Tasks:**
1. Research `like` operator syntax
2. Create policy with pattern matching
3. Test various naming patterns
4. Refine policy rule

**Questions to Answer:**
- How does the `like` operator work?
- What pattern syntax is used?
- How do you handle multiple naming patterns?

**Success Criteria:**
- [ ] Naming policy created
- [ ] Pattern matching works
- [ ] Compliant names allowed
- [ ] Non-compliant names blocked

---

## 🎯 Exercise 12: Policy Testing Framework

**Challenge:** Create a comprehensive testing approach for policies.

**Requirements:**
1. Document test cases for each policy:
   - Compliant scenarios
   - Non-compliant scenarios
   - Edge cases
2. Create test Terraform configurations
3. Create a test script that:
   - Applies policies
   - Tests compliant resources
   - Tests non-compliant resources
   - Reports results
4. Document test results

**Tasks:**
1. Create test case matrix
2. Create test Terraform files
3. Create test script (bash/PowerShell)
4. Run tests and document results

**Questions to Answer:**
- What test cases are important for policies?
- How do you test policy enforcement?
- How do you verify policies work correctly?

**Success Criteria:**
- [ ] Test cases documented
- [ ] Test configurations created
- [ ] Test script works
- [ ] Test results documented

---

## 📝 Notes Section

Use this section to document your findings and answers:

### Exercise 1 - Policy Structure:
- 
- 

### Exercise 2 - Storage Account Policy:
- 
- 

### Exercise 3 - Multiple Locations:
- 
- 

### Exercise 4 - Audit Policy:
- 
- 

### Exercise 5 - Multiple Conditions:
- 
- 

### Exercise 6 - Resource Group Assignment:
- 
- 

### Exercise 7 - Modify Effect:
- 
- 

### Exercise 8 - Policy Exemption:
- 
- 

### Exercise 9 - Policy Set:
- 
- 

### Exercise 10 - Compliance Monitoring:
- 
- 

### Exercise 11 - Naming Convention:
- 
- 

### Exercise 12 - Testing Framework:
- 
- 

### Key Learnings:
1. 
2. 
3. 

### Common Mistakes Made:
1. 
2. 
3. 

### Questions Still Have:
1. 
2. 
3. 

---

## 🏆 Completion Checklist

- [ ] Exercise 1: Policy structure analyzed
- [ ] Exercise 2: Storage account policy created
- [ ] Exercise 3: Location policy enhanced
- [ ] Exercise 4: Audit policy created
- [ ] Exercise 5: Multiple conditions policy created
- [ ] Exercise 6: Resource group assignment tested
- [ ] Exercise 7: Modify effect policy created
- [ ] Exercise 8: Policy exemption created
- [ ] Exercise 9: Policy set created
- [ ] Exercise 10: Compliance monitoring set up
- [ ] Exercise 11: Naming convention policy created
- [ ] Exercise 12: Testing framework created
- [ ] All questions answered
- [ ] Notes section completed

---

## 💡 Tips for Success

1. **Start Simple:** Begin with basic policies and build complexity
2. **Test Incrementally:** Test each policy individually before combining
3. **Use terraform plan:** Always plan before applying policies
4. **Check Azure Portal:** Verify policies in portal for visual confirmation
5. **Read Error Messages:** Policy errors provide helpful information
6. **Document:** Write down what you learn as you go
7. **Experiment:** Try different policy effects and operators

---

## 🚀 Ready to Start?

Begin with Exercise 1 and work through them sequentially. Each exercise builds on concepts from previous ones. Good luck!

**Remember:** These are challenges - figure it out yourself! Use Terraform documentation, Azure Policy documentation, and experimentation to solve them.

