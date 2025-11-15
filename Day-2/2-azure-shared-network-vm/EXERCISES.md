# 🎯 VM Deployment Challenges - Exercises

This file contains challenge-based exercises to enhance your VM deployment with advanced networking, string manipulation, and additional features. You'll need to figure out the implementation yourself!

**👉 For step-by-step instructions on deploying your first VM, see [DEPLOY_FIRST_VM.md](./DEPLOY_FIRST_VM.md)**

## 📚 Prerequisites

Before starting these exercises, ensure you have:
- Completed the basic VM deployment from `DEPLOY_FIRST_VM.md`
- Understanding of Terraform string manipulation functions
- Basic knowledge of Azure networking
- SSH access to your VM working

---

## 🎯 Exercise 1: Dynamic Resource Naming with String Functions

**Challenge:** Use string manipulation functions to create dynamic, standardized resource names.

**Requirements:**
- Create a variable `project_name` with value `"My Awesome Project"`
- Create a variable `environment` with value `"dev"`
- Use `lower()`, `replace()`, and string interpolation to format names:
  - Resource group: `"my-awesome-project-dev-rg"`
  - VM name: `"my-awesome-project-dev-vm"`
  - VNet name: `"my-awesome-project-dev-vnet"`
- All names should be lowercase with hyphens instead of spaces
- Environment should be appended to each name

**Expected Outcome:**
- All resource names follow a consistent pattern
- Names are Azure-compliant (lowercase, no spaces)
- Environment is clearly identifiable in names

**Verification:**
- Run `terraform plan` and verify all names follow the pattern
- Check that names are properly formatted
- Ensure no spaces or uppercase letters in resource names

**Questions to Answer:**
- What happens if `project_name` contains special characters?
- How would you handle a project name that's too long for Azure limits?

---

## 🎯 Exercise 2: Multiple Subnets with for_each

**Challenge:** Create multiple subnets in your VNet using `for_each`.

**Requirements:**
- Create a variable `subnets` as a map:
  ```hcl
  subnets = {
    "web"     = "10.0.1.0/24"
    "app"     = "10.0.2.0/24"
    "database" = "10.0.3.0/24"
  }
  ```
- Use `for_each` to create a subnet for each entry
- Subnet names should be formatted: `"subnet-{key}"` (e.g., `"subnet-web"`)
- Use string manipulation to ensure subnet names are lowercase
- Each subnet should be in the same VNet

**Expected Outcome:**
- Three subnets created dynamically
- Subnet names follow consistent pattern
- All subnets properly configured with correct address prefixes

**Verification:**
- Run `terraform plan` - should show 3 subnets
- Verify subnet names and address prefixes
- Check that all subnets reference the same VNet

**Bonus Challenge:**
- Add a `subnet_tags` variable and apply different tags to each subnet
- Use `merge()` to combine default tags with subnet-specific tags

---

## 🎯 Exercise 3: Network Security Group Rules with Dynamic Blocks

**Challenge:** Create multiple NSG rules dynamically using `split()` and `for_each`.

**Requirements:**
- Create a variable `allowed_ports` as a string: `"80,443,22,3306"`
- Use `split()` to convert the string to a list
- Create a dynamic `security_rule` block that creates a rule for each port
- Rule names should be formatted: `"Allow-{port}-Inbound"`
- Use string manipulation to ensure rule names are properly formatted
- All rules should allow inbound TCP traffic from Internet
- Set priority starting at 1000, incrementing by 10 for each rule

**Expected Outcome:**
- Four NSG rules created dynamically
- Each rule allows the specified port
- Rule names are descriptive and follow a pattern
- Priorities are properly assigned

**Verification:**
- Run `terraform plan` - should show 4 security rules
- Verify each port has a corresponding rule
- Check rule priorities are sequential

**Questions to Answer:**
- How would you add a description to each rule that includes the port number?
- What happens if you add a port that's already in the list?

---

## 🎯 Exercise 4: VM Size Validation with String Functions

**Challenge:** Implement VM size validation using string manipulation functions.

**Requirements:**
- Create a variable `vm_size` with default `"Standard_DS1_v2"`
- Add validation rules:
  1. VM size must be between 5 and 30 characters long
  2. Must contain "standard" (case-insensitive)
  3. Must end with "v2" or "v3"
- Use `length()`, `contains()`, `lower()`, and `endswith()` functions
- Provide clear error messages for each validation failure

**Expected Outcome:**
- Invalid VM sizes are rejected with helpful error messages
- Valid VM sizes pass validation
- Error messages guide users to fix the issue

**Verification:**
- Test with valid size: `"Standard_DS1_v2"` - should pass
- Test with invalid length: `"DS1"` - should fail
- Test without "standard": `"Basic_A0"` - should fail
- Test without version: `"Standard_DS1"` - should fail

**Questions to Answer:**
- How do you make string comparisons case-insensitive?
- Can you have multiple validation blocks? What happens if one fails?

---

## 🎯 Exercise 5: Tag Management with String Manipulation

**Challenge:** Create dynamic tags using string functions and merge operations.

**Requirements:**
- Create variables:
  - `project_name` = `"My Project"`
  - `environment` = `"production"`
  - `cost_center` = `"CC-12345"`
- Create default tags local:
  ```hcl
  default_tags = {
    managed_by = "terraform"
    created_date = <current date in YYYY-MM-DD format>
  }
  ```
- Create project tags using string manipulation:
  - `project` = lowercase project name with hyphens
  - `environment` = lowercase environment name
  - `cost_center` = uppercase cost center
- Merge default and project tags
- Apply merged tags to all resources (RG, VNet, VM, etc.)

**Expected Outcome:**
- All resources have consistent tags
- Tags include project, environment, and cost center
- Tags are properly formatted (lowercase, uppercase as needed)
- Created date is automatically added

**Verification:**
- Run `terraform plan` and check tags on each resource
- Verify tag formatting is correct
- Ensure all resources have the same tag set

**Bonus Challenge:**
- Use `formatdate()` to add timestamp to tags
- Create different tag sets for different resource types

---

## 🎯 Exercise 6: Public IP with Conditional Allocation

**Challenge:** Make public IP allocation method configurable with validation.

**Requirements:**
- Create a variable `use_static_ip` (boolean, default `false`)
- If `true`, use `allocation_method = "Static"`
- If `false`, use `allocation_method = "Dynamic"`
- Use conditional expression: `var.use_static_ip ? "Static" : "Dynamic"`
- Add validation to ensure variable is boolean type
- Public IP name should include allocation type: `"public-ip-{allocation-type}"`

**Expected Outcome:**
- Public IP allocation method is configurable
- Name reflects the allocation method
- Validation ensures correct variable type

**Verification:**
- Test with `use_static_ip = false` - should create Dynamic IP
- Test with `use_static_ip = true` - should create Static IP
- Test with invalid value - should fail validation

**Questions to Answer:**
- What's the difference between Static and Dynamic IPs?
- When would you want to use a Static IP?

---

## 🎯 Exercise 7: Multiple Network Interfaces

**Challenge:** Create a VM with multiple network interfaces using `for_each`.

**Requirements:**
- Create a variable `network_interfaces` as a map:
  ```hcl
  network_interfaces = {
    "primary"   = "10.0.1.10"
    "secondary" = "10.0.2.10"
  }
  ```
- Create multiple NICs, one for each entry
- Each NIC should:
  - Connect to a different subnet (use the subnets from Exercise 2)
  - Have a static private IP from the map
  - Be named: `"nic-{key}"`
- Attach all NICs to the VM
- Use string manipulation for naming

**Expected Outcome:**
- Multiple NICs created dynamically
- Each NIC connected to appropriate subnet
- VM has multiple network interfaces
- NICs have static IP addresses as specified

**Verification:**
- Run `terraform plan` - should show multiple NICs
- Verify each NIC connects to correct subnet
- Check VM has all NICs attached
- Verify IP addresses match the variable values

**Questions to Answer:**
- Why might you want multiple NICs on a VM?
- What are the limitations of multiple NICs in Azure?

---

## 🎯 Exercise 8: Storage Account Naming with Constraints

**Challenge:** Create a storage account with Azure-compliant naming using string functions.

**Requirements:**
- Create a variable `storage_account_name` = `"MyProjectStorageAccount"`
- Format the name to meet Azure requirements:
  - 3-24 characters long
  - Lowercase only
  - Alphanumeric only (no special characters, no spaces)
  - Must be globally unique (add random suffix)
- Use `lower()`, `replace()`, `substr()`, and `random_id` data source
- Create a storage account with the formatted name
- Add validation to ensure input name is reasonable

**Expected Outcome:**
- Storage account name meets all Azure requirements
- Name is properly formatted
- Validation prevents invalid names

**Verification:**
- Run `terraform plan` - verify storage account name format
- Check name length is within limits
- Verify no uppercase or special characters
- Test with various input names

**Questions to Answer:**
- How do you ensure storage account name uniqueness?
- What happens if the formatted name is still too long?

---

## 🎯 Exercise 9: NSG Rules from CSV-like String

**Challenge:** Parse a complex string to create multiple NSG rules with different configurations.

**Requirements:**
- Create a variable `nsg_rules` as a string:
  ```hcl
  nsg_rules = "SSH:22:1001:Internet,HTTP:80:1010:10.0.0.0/24,HTTPS:443:1020:10.0.0.0/24"
  ```
- Format: `"Name:Port:Priority:Source"`
- Use `split()` to parse the string
- Create dynamic security rules with:
  - Name from first part
  - Port from second part
  - Priority from third part
  - Source from fourth part
- Use string manipulation to format rule names properly

**Expected Outcome:**
- Multiple NSG rules created from single string
- Each rule has correct name, port, priority, and source
- Rules are properly formatted

**Verification:**
- Run `terraform plan` - should show 3 security rules
- Verify each rule has correct configuration
- Check rule names are properly formatted

**Questions to Answer:**
- How would you handle invalid format in the string?
- What if you need to add more fields to each rule?

---

## 🎯 Exercise 10: VM Configuration Lookup with String Manipulation

**Challenge:** Use `lookup()` with string manipulation to get environment-specific VM configurations.

**Requirements:**
- Create a variable `environment` = `"dev"`
- Create a map `vm_configs`:
  ```hcl
  vm_configs = {
    dev = {
      size = "Standard_B1ls"
      disk_type = "Standard_LRS"
    }
    prod = {
      size = "Standard_DS2_v2"
      disk_type = "Premium_LRS"
    }
  }
  ```
- Use `lookup()` to get config for current environment
- Use `lower()` to ensure case-insensitive environment matching
- Apply configuration to VM
- Add fallback to "dev" if environment not found
- Format VM name to include environment: `"{project}-{environment}-vm"`

**Expected Outcome:**
- VM size and disk type vary by environment
- Environment name is included in VM name
- Fallback works for invalid environments

**Verification:**
- Test with `environment = "dev"` - should use B1ls and Standard_LRS
- Test with `environment = "prod"` - should use DS2_v2 and Premium_LRS
- Test with invalid environment - should fallback to dev config

**Questions to Answer:**
- How does `lookup()` handle missing keys?
- How would you add more configuration options?

---

## 🎯 Exercise 11: Resource Name Prefix with Validation

**Challenge:** Create a reusable prefix system with string validation.

**Requirements:**
- Create a variable `resource_prefix` = `"myproject"`
- Add validation:
  - Must be 3-15 characters
  - Must be lowercase
  - Must start with a letter
  - Can only contain letters, numbers, and hyphens
- Use the prefix in all resource names:
  - Format: `"{prefix}-{resource-type}-{identifier}"`
- Create a local that formats the prefix consistently
- Apply to at least 5 different resources

**Expected Outcome:**
- All resources use consistent naming with prefix
- Invalid prefixes are rejected
- Prefix is properly formatted

**Verification:**
- Test with valid prefix - should work
- Test with uppercase - should fail
- Test with special characters - should fail
- Test with too short/long - should fail
- Verify all resources use the prefix

**Questions to Answer:**
- Why is consistent naming important?
- How would you enforce naming conventions across a team?

---

## 🎯 Exercise 12: Complete Infrastructure with String Manipulation

**Challenge:** Combine all previous exercises into a complete, production-ready configuration.

**Requirements:**
- Use all string manipulation techniques from previous exercises
- Create a comprehensive VM deployment with:
  - Dynamic resource naming
  - Multiple subnets
  - Dynamic NSG rules
  - Validated VM size
  - Proper tagging
  - Environment-specific configuration
- All names should use consistent formatting
- All tags should be dynamically generated
- Add outputs for important values (formatted)

**Expected Outcome:**
- Complete, production-ready configuration
- All resources properly named and tagged
- Configuration is maintainable and scalable
- String manipulation used throughout

**Verification:**
- Run `terraform plan` - should show all resources
- Verify naming consistency
- Check tag consistency
- Ensure all validations work
- Test with different environments

**Questions to Answer:**
- How does string manipulation improve maintainability?
- What are the benefits of dynamic resource naming?

---

## 📊 Exercise Checklist

Complete each exercise and verify:

- [ ] Exercise 1: Dynamic resource naming implemented
- [ ] Exercise 2: Multiple subnets with for_each
- [ ] Exercise 3: Dynamic NSG rules
- [ ] Exercise 4: VM size validation
- [ ] Exercise 5: Tag management
- [ ] Exercise 6: Conditional public IP
- [ ] Exercise 7: Multiple network interfaces
- [ ] Exercise 8: Storage account naming
- [ ] Exercise 9: NSG rules from string
- [ ] Exercise 10: VM configuration lookup
- [ ] Exercise 11: Resource name prefix
- [ ] Exercise 12: Complete infrastructure

---

## 🎓 Key Concepts to Master

After completing these exercises, you should understand:

1. **String Manipulation:**
   - `lower()`, `upper()`, `replace()`, `substr()`
   - `split()`, `join()`, `formatdate()`
   - String interpolation and concatenation

2. **Dynamic Resource Creation:**
   - `for_each` for multiple resources
   - `dynamic` blocks for repeated configurations
   - Conditional expressions

3. **Validation:**
   - Variable validation blocks
   - Input sanitization
   - Error message formatting

4. **Resource Organization:**
   - Consistent naming conventions
   - Tag management
   - Environment separation

---

## 🐛 Common Pitfalls

Watch out for these common mistakes:

1. **Case sensitivity** - Azure resource names are case-insensitive but should be consistent
2. **String length limits** - Azure has limits on resource name lengths
3. **Special characters** - Not all special characters are allowed in Azure names
4. **Global uniqueness** - Storage accounts and some resources must be globally unique
5. **Function order** - Order matters when chaining string functions
6. **Validation logic** - Complex validations can be hard to debug

---

## 💡 Bonus Challenges

1. **Multi-Environment Setup:**
   - Create separate configurations for dev/staging/prod
   - Use workspaces or variables to switch environments
   - Ensure resource naming distinguishes environments

2. **Cost Optimization:**
   - Use smaller VM sizes for dev environments
   - Implement auto-shutdown schedules
   - Add cost tags for tracking

3. **Security Hardening:**
   - Restrict NSG rules to specific IP ranges
   - Implement Azure Key Vault for secrets
   - Add monitoring and alerting

4. **Advanced Networking:**
   - Create VPN gateway
   - Implement peering between VNets
   - Add load balancer

---

## 📚 Additional Resources

- [Terraform String Functions](https://developer.hashicorp.com/terraform/language/functions#string-functions)
- [Azure Naming Conventions](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Terraform for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Azure VM Sizes](https://docs.microsoft.com/azure/virtual-machines/sizes)

---

## ✅ Completion

Once you've completed all exercises and can:
- Use string manipulation functions effectively
- Create dynamic resources with for_each
- Validate inputs properly
- Organize resources with consistent naming
- Apply production-ready configurations

You've mastered advanced VM deployment with Terraform! 🎉

---

## 📝 Notes Section

Use this space to document your findings and solutions:

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

**Exercise 10 Notes:**
- 

**Exercise 11 Notes:**
- 

**Exercise 12 Notes:**
- 

