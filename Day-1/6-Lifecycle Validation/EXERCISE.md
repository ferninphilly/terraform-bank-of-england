# 🔄 Terraform Lifecycle Rules - Challenge Exercises

This exercise guide provides challenges for implementing Terraform lifecycle rules. **Figure out the implementation yourself** - these are challenges, not tutorials!

## 📚 Prerequisites

- Understanding of Terraform resource blocks
- Basic knowledge of Azure resources
- Access to Azure subscription
- Terraform installed and configured
- Completed the basic task.md walkthrough (recommended)

---

## 🎯 Challenge 1: create_before_destroy - Zero Downtime Migration

**Challenge:** Implement `create_before_destroy` lifecycle rule for a storage account to ensure zero downtime during name changes.

**Requirements:**
- Add lifecycle block to `azurerm_storage_account` resource
- Set `create_before_destroy = true`
- Test by changing one storage account name in `terraform.tfvars`
- Verify the operation order in `terraform plan`

**Expected Outcome:**
- When you run `terraform plan`, you should see `+/-` (create before destroy) instead of `-/+` (destroy before create)
- During `terraform apply`, the new resource is created first, then the old one is destroyed
- Both resources exist briefly during the transition

**Verification Steps:**
1. Run `terraform plan` and observe the operation order
2. Look for `+/-` symbol indicating create-before-destroy
3. Run `terraform apply` and watch the resource creation sequence
4. Verify both resources exist simultaneously during transition (check Azure Portal)

**Questions to Answer:**
- What happens if you don't use `create_before_destroy`? What's the default behavior?
- Why is this important for production resources?
- Can you use `create_before_destroy` with `prevent_destroy`? What happens?

**Success Criteria:**
- [ ] Plan shows `+/-` operation order
- [ ] New resource created before old one destroyed
- [ ] No downtime during transition

---

## 🎯 Challenge 2: prevent_destroy - Protect Critical Resources

**Challenge:** Protect a storage account from accidental deletion using `prevent_destroy`.

**Requirements:**
- Add `prevent_destroy = true` to the storage account lifecycle block
- Attempt to change the storage account name (which requires replacement)
- Attempt to destroy the resource using `terraform destroy`
- Document what happens in each case

**Expected Outcome:**
- `terraform plan` should fail with an error when trying to replace the resource
- `terraform destroy` should fail with an error preventing destruction
- Error message should clearly indicate the resource cannot be destroyed

**Verification Steps:**
1. Add `prevent_destroy = true` to storage account lifecycle
2. Change storage account name in configuration
3. Run `terraform plan` - should fail
4. Run `terraform destroy` - should fail
5. Document the exact error messages

**Questions to Answer:**
- Does `prevent_destroy` prevent manual deletion in Azure Portal? (Test it!)
- How would you actually destroy a protected resource if needed?
- What's the difference between `prevent_destroy` and Azure resource locks?
- Can you temporarily disable `prevent_destroy` to allow destruction?

**Bonus Challenge:**
- Create a conditional `prevent_destroy` that only protects resources in production:
  ```hcl
  prevent_destroy = var.environment == "prod" ? true : false
  ```

**Success Criteria:**
- [ ] Plan fails when trying to replace resource
- [ ] Destroy fails with clear error message
- [ ] Understand how to remove protection when needed

---

## 🎯 Challenge 3: ignore_changes - Prevent Configuration Drift

**Challenge:** Use `ignore_changes` to prevent Terraform from managing specific resource attributes.

**Requirements:**
- Add `ignore_changes` to the storage account lifecycle block
- Ignore changes to `account_replication_type`
- Apply your configuration
- Manually change `account_replication_type` in Azure Portal (e.g., from GRS to LRS)
- Run `terraform plan` and observe the result

**Expected Outcome:**
- After manual change, `terraform plan` should show "No changes"
- The manual change persists and is not reverted by Terraform
- Terraform ignores the attribute listed in `ignore_changes`

**Verification Steps:**
1. Apply configuration with `account_replication_type = "GRS"`
2. Manually change to "LRS" in Azure Portal
3. Run `terraform plan` - should show no changes
4. Remove the attribute from `ignore_changes` and run plan again - should show the drift
5. Restore `ignore_changes` and verify plan shows no changes again

**Questions to Answer:**
- What happens if you use `ignore_changes = all`? (Try it!)
- When would you want to ignore tag changes?
- What's the difference between `ignore_changes` and not defining an attribute?
- Can you ignore nested attributes? (e.g., `ignore_changes = [tags.Environment]`)

**Bonus Challenge:**
- Implement `ignore_changes` on the resource group to ignore name changes
- Try changing the resource group name in your configuration
- Observe what happens

**Success Criteria:**
- [ ] Manual changes to ignored attributes persist
- [ ] Plan shows no changes for ignored attributes
- [ ] Understand when to use `ignore_changes`

---

## 🎯 Challenge 4: replace_triggered_by - Dependency-Driven Replacement

**Challenge:** Force resource replacement when a dependency changes using `replace_triggered_by`.

**Requirements:**
- Add `replace_triggered_by` to the storage account lifecycle block
- Reference the resource group ID: `azurerm_resource_group.example.id`
- Change the resource group name
- Run `terraform plan` and observe what happens to the storage account

**Expected Outcome:**
- When the resource group changes, the storage account should be replaced
- Plan should show storage account will be destroyed and recreated
- This ensures consistency between related resources

**Verification Steps:**
1. Add `replace_triggered_by = [azurerm_resource_group.example.id]` to storage account lifecycle
2. Change the resource group name in configuration
3. Run `terraform plan`
4. Verify storage accounts are marked for replacement
5. Observe the dependency relationship

**Questions to Answer:**
- Why might you want to replace a resource when its dependency changes?
- What's the difference between `replace_triggered_by` and `create_before_destroy`?
- Can you reference multiple resources in `replace_triggered_by`?
- What happens if you combine `replace_triggered_by` with `prevent_destroy`?

**Bonus Challenge:**
- Create a scenario where changing a tag on the resource group triggers storage account replacement
- Use `replace_triggered_by = [azurerm_resource_group.example.tags]`

**Success Criteria:**
- [ ] Storage account replaced when resource group changes
- [ ] Understand dependency-driven replacement
- [ ] Can combine with other lifecycle rules

---

## 🎯 Challenge 5: precondition - Location Validation

**Challenge:** Create a custom validation that prevents resources from being created in "canada central".

**Requirements:**
- Add a `precondition` block to the resource group lifecycle
- Condition should check that `var.location != "canada central"`
- Provide a clear, helpful error message explaining why Canada Central is not allowed
- Test with both valid and invalid locations

**Expected Outcome:**
- When location is "canada central", `terraform plan` should fail with your custom error message
- When location is valid, plan should succeed
- Error message should be clear and actionable

**Verification Steps:**
1. Add precondition to resource group lifecycle
2. Set `location = "canada central"` in `terraform.tfvars`
3. Run `terraform plan` - should fail with your error message
4. Change to a valid location and run plan again - should succeed
5. Verify error message is helpful

**Questions to Answer:**
- When does a `precondition` get evaluated? (Before or after resource creation?)
- Can you have multiple `precondition` blocks? (Try it!)
- What happens if one precondition fails but others pass?
- Can preconditions reference other resources?

**Bonus Challenge:**
- Create a precondition that validates the location is in the `allowed_locations` list
- Use `contains()` function to check if location is allowed
- Provide an error message that lists all allowed locations:
  ```hcl
  error_message = "Location '${var.location}' is not allowed. Allowed locations: ${join(", ", var.allowed_locations)}"
  ```

**Success Criteria:**
- [ ] Plan fails with custom error for "canada central"
- [ ] Plan succeeds for valid locations
- [ ] Error message is clear and helpful

---

## 🎯 Challenge 6: precondition - Advanced Multi-Condition Validation

**Challenge:** Create multiple preconditions to validate different aspects of your configuration.

**Requirements:**
- Create a precondition that validates `environment` is not empty
- Create a precondition that validates `location` is in `allowed_locations`
- Create a precondition that validates storage account name length (3-24 characters)
- Test each precondition individually
- Ensure all preconditions provide specific, actionable error messages

**Expected Outcome:**
- Each precondition should provide a specific error message
- All preconditions must pass for the resource to be created
- Invalid values should result in clear, actionable error messages

**Verification Steps:**
1. Test with empty environment variable - should fail with specific error
2. Test with invalid location - should fail with location-specific error
3. Test with storage account name that's too short (< 3 chars) - should fail
4. Test with storage account name that's too long (> 24 chars) - should fail
5. Verify each error message is helpful and specific

**Questions to Answer:**
- What happens if one precondition fails but others pass?
- Can preconditions reference other resources? (Try referencing `azurerm_resource_group.example.name`)
- Can you use functions in precondition conditions? (Try `length()`, `substr()`, etc.)
- What's the evaluation order if multiple preconditions fail?

**Bonus Challenge:**
- Create a precondition that validates storage account name format (lowercase, alphanumeric only)
- Use regex or string functions to validate the format
- Provide error message explaining the naming requirements

**Success Criteria:**
- [ ] Multiple preconditions work together
- [ ] Each provides specific error message
- [ ] All must pass for resource creation

---

## 🎯 Challenge 7: postcondition - Post-Creation Validation

**Challenge:** Validate resource state after creation using `postcondition`.

**Requirements:**
- Add a `postcondition` block to the storage account lifecycle
- Validate that `account_tier` is "Standard"
- Validate that the storage account name length is between 3 and 24 characters
- Use `self` to reference the resource's attributes
- Test with valid and invalid configurations

**Expected Outcome:**
- After resource creation, postconditions are evaluated
- If validation fails, Terraform reports an error
- Resource may be marked as tainted if postcondition fails

**Verification Steps:**
1. Add postcondition to storage account lifecycle
2. Apply configuration with valid values - should succeed
3. Try to create resource with invalid configuration (if possible)
4. Observe postcondition validation
5. Check if resource is marked as tainted

**Questions to Answer:**
- What's the difference between `precondition` and `postcondition`?
- When would you use `postcondition` instead of `precondition`?
- Can `postcondition` reference other resources? (Try it!)
- What happens if a postcondition fails? Does the resource get destroyed?

**Bonus Challenge:**
- Create a postcondition that validates the storage account was created in the correct region
- Compare `self.location` with `var.location`
- Provide error message if mismatch detected

**Success Criteria:**
- [ ] Postcondition validates after creation
- [ ] Understand difference from precondition
- [ ] Can use `self` to reference resource attributes

---

## 🎯 Challenge 8: Combining Lifecycle Rules - The Ultimate Challenge

**Challenge:** Create a comprehensive lifecycle block that combines multiple rules without conflicts.

**Requirements:**
- Combine `create_before_destroy`, `prevent_destroy`, `ignore_changes`, and `precondition` in a single lifecycle block
- Apply to the storage account resource
- Ensure rules don't conflict with each other
- Test the complete lifecycle configuration

**Expected Outcome:**
- All lifecycle rules work together harmoniously
- Resource is protected from destruction
- Creates before destroying when needed
- Ignores specified attribute changes
- Validates location before creation

**Verification Steps:**
1. Combine all lifecycle rules in storage account
2. Test each rule individually to ensure it still works
3. Test combinations of rules
4. Verify no conflicts between rules
5. Document any interactions you discover

**Questions to Answer:**
- Can `prevent_destroy` and `create_before_destroy` work together? (Think about this!)
- What happens if you ignore an attribute that's also in `replace_triggered_by`?
- Can you have both `precondition` and `postcondition` in the same lifecycle block?
- What's the evaluation order: preconditions → creation → postconditions?

**Bonus Challenge:**
- Create environment-specific lifecycle rules:
  - Production: prevent destroy, strict validation, create before destroy
  - Development: allow changes, less strict validation, no prevent destroy
- Use conditional expressions based on `var.environment`

**Success Criteria:**
- [ ] All lifecycle rules work together
- [ ] No conflicts between rules
- [ ] Understand rule interactions

---

## 🎯 Challenge 9: Real-World Scenarios

### Scenario 9.1: Production Database Protection

**Challenge:** Create lifecycle rules for a production database resource.

**Requirements:**
- Prevent destruction (critical data!)
- Create before destroy for updates (zero downtime)
- Ignore tag changes (tags managed by Azure Policy)
- Validate database SKU is in allowed list

**Success Criteria:**
- [ ] Database protected from accidental deletion
- [ ] Updates happen with zero downtime
- [ ] Tags can change without Terraform interference
- [ ] Only approved SKUs can be used

---

### Scenario 9.2: Auto-Scaling Configuration

**Challenge:** Create lifecycle rules for a VM scale set that allows auto-scaling.

**Requirements:**
- Ignore changes to `instances` count (allows auto-scaling to work)
- Prevent destruction (protect the scale set)
- Validate VM size is in allowed list using precondition
- Create before destroy for configuration updates

**Success Criteria:**
- [ ] Instance count can change via auto-scaling
- [ ] Scale set protected from deletion
- [ ] Only approved VM sizes allowed
- [ ] Configuration updates are zero-downtime

---

### Scenario 9.3: Environment-Specific Rules

**Challenge:** Create lifecycle rules that behave differently based on environment.

**Requirements:**
- Production: prevent destroy, strict validation, create before destroy
- Development: allow changes, less strict validation, no prevent destroy
- Staging: moderate protection, some validation

**Implementation Hint:**
```hcl
lifecycle {
  prevent_destroy = var.environment == "prod" ? true : false
  create_before_destroy = var.environment == "prod" ? true : false
  # ... other rules
}
```

**Success Criteria:**
- [ ] Rules adapt based on environment
- [ ] Production has maximum protection
- [ ] Development allows flexibility

---

## 📝 Notes Section

Use this section to document your findings, observations, and answers to questions:

### My Findings:

**Challenge 1 - create_before_destroy:**
- 
- 

**Challenge 2 - prevent_destroy:**
- 
- 

**Challenge 3 - ignore_changes:**
- 
- 

**Challenge 4 - replace_triggered_by:**
- 
- 

**Challenge 5 - precondition:**
- 
- 

**Challenge 6 - Advanced preconditions:**
- 
- 

**Challenge 7 - postcondition:**
- 
- 

**Challenge 8 - Combining rules:**
- 
- 

**Challenge 9 - Real-world scenarios:**
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

- [ ] Challenge 1: create_before_destroy implemented and tested
- [ ] Challenge 2: prevent_destroy implemented and tested
- [ ] Challenge 3: ignore_changes implemented and tested
- [ ] Challenge 4: replace_triggered_by implemented and tested
- [ ] Challenge 5: precondition for location validation implemented
- [ ] Challenge 6: Multiple preconditions implemented
- [ ] Challenge 7: postcondition implemented and tested
- [ ] Challenge 8: Combined lifecycle rules working
- [ ] Challenge 9: Real-world scenarios completed
- [ ] All questions answered
- [ ] Notes section completed

---

## 💡 Tips for Success

1. **Read the Error Messages:** Terraform provides helpful error messages - read them carefully!

2. **Test Incrementally:** Don't try to implement everything at once. Test each rule individually first.

3. **Use terraform plan:** Always run `terraform plan` before `apply` to see what will happen.

4. **Check Azure Portal:** Verify actual resource state in Azure Portal, not just Terraform state.

5. **Experiment:** Try breaking things (safely!) to understand how lifecycle rules work.

6. **Document:** Write down your observations - you'll learn more by documenting what you discover.

---

## 🚀 Ready to Start?

Begin with Challenge 1 and work through them sequentially. Each challenge builds on concepts from previous ones. Good luck!

**Remember:** These are challenges - figure it out yourself! Use the Terraform documentation, error messages, and experimentation to solve them.
