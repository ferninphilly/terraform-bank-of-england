# 🔄 Terraform Lifecycle Rules - Exercises

This exercise guide provides challenges for implementing Terraform lifecycle rules. You'll need to figure out the implementation details yourself!

## 📚 Prerequisites

- Understanding of Terraform resource blocks
- Basic knowledge of Azure resources
- Access to Azure subscription
- Terraform installed and configured

---

## 🎯 Exercise 1: create_before_destroy

**Challenge:** Implement `create_before_destroy` lifecycle rule for a storage account.

**Requirements:**
- Add lifecycle block to `azurerm_storage_account` resource
- Set `create_before_destroy = true`
- Test by changing the storage account name
- Verify that the new resource is created before the old one is destroyed

**Expected Outcome:**
- When you run `terraform plan`, you should see `+/-` (create before destroy) instead of `-/+` (destroy before create)
- During `terraform apply`, the new resource is created first, then the old one is destroyed
- No downtime occurs during the transition

**Verification:**
- Run `terraform plan` and observe the operation order
- Run `terraform apply` and watch the resource creation sequence
- Confirm both resources exist briefly during the transition

---

## 🎯 Exercise 2: prevent_destroy

**Challenge:** Protect a storage account from accidental deletion using `prevent_destroy`.

**Requirements:**
- Add `prevent_destroy = true` to the storage account lifecycle block
- Attempt to change the storage account name (which requires replacement)
- Attempt to destroy the resource
- Observe what happens in each case

**Expected Outcome:**
- `terraform plan` should fail with an error when trying to replace the resource
- `terraform destroy` should fail with an error preventing destruction
- Error message should indicate the resource cannot be destroyed

**Verification:**
- Try to change a resource attribute that requires replacement
- Try to run `terraform destroy`
- Document the error messages you receive

**Questions to Answer:**
- Does `prevent_destroy` prevent manual deletion in Azure Portal?
- How would you actually destroy a protected resource if needed?

---

## 🎯 Exercise 3: ignore_changes

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

**Verification:**
- Make a manual change to the ignored attribute
- Run `terraform plan` - should show no changes
- Remove the attribute from `ignore_changes` and run plan again - should show the drift

**Bonus Challenge:**
- Implement `ignore_changes` on the resource group to ignore name changes
- Try changing the resource group name in your configuration
- Observe what happens

**Questions to Answer:**
- What happens if you use `ignore_changes = all`?
- When would you want to ignore tag changes?

---

## 🎯 Exercise 4: replace_triggered_by

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

**Verification:**
- Change the resource group name
- Run `terraform plan`
- Verify storage accounts are marked for replacement

**Questions to Answer:**
- Why might you want to replace a resource when its dependency changes?
- What's the difference between `replace_triggered_by` and `create_before_destroy`?

---

## 🎯 Exercise 5: precondition - Location Validation

**Challenge:** Create a custom validation that prevents resources from being created in "canada central".

**Requirements:**
- Add a `precondition` block to the resource group lifecycle
- Condition should check that `var.location != "canada central"`
- Provide a clear error message explaining why Canada Central is not allowed
- Test with both valid and invalid locations

**Expected Outcome:**
- When location is "canada central", `terraform plan` should fail with your custom error message
- When location is valid, plan should succeed
- Error message should be clear and helpful

**Verification:**
- Set `location = "canada central"` in `terraform.tfvars`
- Run `terraform plan` - should fail with your error message
- Change to a valid location and run plan again - should succeed

**Bonus Challenge:**
- Create a precondition that validates the location is in the `allowed_locations` list
- Use `contains()` function to check if location is allowed
- Provide an error message that lists all allowed locations

**Questions to Answer:**
- When does a `precondition` get evaluated?
- Can you have multiple `precondition` blocks?

---

## 🎯 Exercise 6: precondition - Advanced Validation

**Challenge:** Create multiple preconditions to validate different aspects of your configuration.

**Requirements:**
- Create a precondition that validates `environment` is not empty
- Create a precondition that validates `location` is in `allowed_locations`
- Create a precondition that validates storage account name length (3-24 characters)
- Test each precondition individually

**Expected Outcome:**
- Each precondition should provide a specific error message
- All preconditions must pass for the resource to be created
- Invalid values should result in clear, actionable error messages

**Verification:**
- Test with empty environment variable
- Test with invalid location
- Test with storage account name that's too short or too long
- Verify each error message is helpful

**Questions to Answer:**
- What happens if one precondition fails but others pass?
- Can preconditions reference other resources?

---

## 🎯 Exercise 7: postcondition

**Challenge:** Validate resource state after creation using `postcondition`.

**Requirements:**
- Add a `postcondition` block to the storage account lifecycle
- Validate that `account_tier` is "Standard"
- Validate that the storage account name length is between 3 and 24 characters
- Use `self` to reference the resource's attributes

**Expected Outcome:**
- After resource creation, postconditions are evaluated
- If validation fails, Terraform reports an error
- Resource may be marked as tainted if postcondition fails

**Verification:**
- Apply configuration with valid values - should succeed
- Try to create resource with invalid `account_tier` (if possible)
- Observe postcondition validation

**Questions to Answer:**
- What's the difference between `precondition` and `postcondition`?
- When would you use `postcondition` instead of `precondition`?

---

## 🎯 Exercise 8: Combining Lifecycle Rules

**Challenge:** Create a comprehensive lifecycle block that combines multiple rules.

**Requirements:**
- Combine `create_before_destroy`, `prevent_destroy`, `ignore_changes`, and `precondition` in a single lifecycle block
- Apply to the storage account resource
- Ensure rules don't conflict with each other
- Test the complete lifecycle configuration

**Expected Outcome:**
- All lifecycle rules work together
- Resource is protected from destruction
- Creates before destroying when needed
- Ignores specified attribute changes
- Validates location before creation

**Verification:**
- Test each lifecycle rule individually
- Test combinations of rules
- Verify no conflicts between rules

**Questions to Answer:**
- Can `prevent_destroy` and `create_before_destroy` work together?
- What happens if you ignore an attribute that's also in `replace_triggered_by`?

---

## 🎯 Exercise 9: Real-World Scenarios

**Challenge 9.1: Production Database Protection**
- Create a lifecycle block for a production database
- Prevent destruction
- Create before destroy for updates
- Ignore tag changes (tags managed separately)

**Challenge 9.2: Auto-Scaling Configuration**
- Create a lifecycle block for a VM scale set
- Ignore changes to `instances` count (allows auto-scaling)
- Prevent destruction
- Validate VM size is in allowed list

**Challenge 9.3: Environment-Specific Rules**
- Create lifecycle rules that behave differently based on environment
- Production: prevent destroy, strict validation
- Development: allow changes, less strict validation
- Use variables to control lifecycle behavior

**Expected Outcome:**
- Each scenario has appropriate lifecycle rules
- Rules match the use case requirements
- Configuration is maintainable and clear

---

## 📊 Exercise Checklist

Complete each exercise and verify:

- [ ] Exercise 1: `create_before_destroy` implemented and tested
- [ ] Exercise 2: `prevent_destroy` implemented and tested
- [ ] Exercise 3: `ignore_changes` implemented and tested
- [ ] Exercise 4: `replace_triggered_by` implemented and tested
- [ ] Exercise 5: `precondition` for location validation implemented
- [ ] Exercise 6: Multiple `precondition` blocks implemented
- [ ] Exercise 7: `postcondition` implemented and tested
- [ ] Exercise 8: Combined lifecycle rules implemented
- [ ] Exercise 9: Real-world scenarios completed

---

## 🎓 Key Concepts to Understand

After completing these exercises, you should understand:

1. **When to use each lifecycle rule:**
   - `create_before_destroy` - Minimize downtime
   - `prevent_destroy` - Protect critical resources
   - `ignore_changes` - Handle external changes
   - `replace_triggered_by` - Maintain consistency
   - `precondition` - Validate before creation
   - `postcondition` - Validate after creation

2. **How lifecycle rules interact:**
   - Rules can be combined
   - Some rules may conflict
   - Order of operations matters

3. **Best practices:**
   - Use lifecycle rules judiciously
   - Document why rules are needed
   - Test lifecycle rules thoroughly
   - Understand the implications

---

## 🐛 Common Pitfalls

Watch out for these common mistakes:

1. **Setting `prevent_destroy = true` on everything** - Makes updates difficult
2. **Using `ignore_changes = all`** - Stops Terraform from managing the resource
3. **Forgetting that `prevent_destroy` only works in Terraform** - Doesn't prevent manual deletion
4. **Overusing `ignore_changes`** - Can hide important configuration drift
5. **Complex `precondition` logic** - Can be hard to debug when they fail

---

## 💡 Bonus Challenges

1. **Dynamic Lifecycle Rules:**
   - Use variables to control lifecycle rules
   - Different rules for different environments
   - Conditional lifecycle blocks

2. **Advanced Validation:**
   - Validate resource names match naming conventions
   - Check resource limits before creation
   - Validate cost-related attributes

3. **Lifecycle with Modules:**
   - Pass lifecycle rules to modules
   - Module-level lifecycle management
   - Reusable lifecycle patterns

---

## 📚 Resources

- [Terraform Lifecycle Documentation](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform Preconditions and Postconditions](https://developer.hashicorp.com/terraform/language/expressions/custom-conditions)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#best-practices)

---

## ✅ Completion

Once you've completed all exercises and can:
- Implement each lifecycle rule correctly
- Understand when to use each rule
- Combine multiple lifecycle rules
- Debug lifecycle-related issues
- Apply lifecycle rules to real-world scenarios

You've mastered Terraform lifecycle management! 🎉

---

## 📝 Notes Section

Use this space to document your findings, observations, and answers to questions:

**Exercise 1 Notes:**
- 

**Exercise 2 Notes:**
- 

**Exercise 3 Notes:**
- 

**Exercise 4 Notes:**
- 

**Exercise 5 Notes:**
- 

**Exercise 6 Notes:**
- 

**Exercise 7 Notes:**
- 

**Exercise 8 Notes:**
- 

**Exercise 9 Notes:**
- 

