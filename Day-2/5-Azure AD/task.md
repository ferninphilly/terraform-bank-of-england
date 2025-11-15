# Task for Day-2 Step 5 - Azure AD User and Group Management

This module focuses on managing Azure Active Directory (Azure AD) users and groups using Terraform, including reading from CSV files, creating users, creating groups, and managing group memberships.

## Learning Objectives

By completing this task, you will learn:
- How to read and parse CSV files in Terraform
- How to create Azure AD users programmatically
- How to create Azure AD security groups
- How to manage group memberships
- How to use `for_each` and `csvdecode()` functions
- How to use data sources to query Azure AD domains

## Assignment Requirements

1. **Create a CSV file** for Active Directory users using the provided sample data
2. **Follow the video tutorial** and create AD users, groups, and user-to-group associations
3. **Create more users** by adding entries to the CSV file
4. **Add one user** to an existing group
5. **Create another group** for Customer Success and add the new user to that group
6. **Use service principal** for authentication (assumed to be already configured)

## Prerequisites

Before starting, ensure you have:
- Azure AD provider configured with service principal authentication
- Terraform initialized in this directory
- Appropriate permissions to create Azure AD users and groups

## Step-by-Step Instructions

### Step 1: Review the CSV File Structure

The `users.csv` file should have the following structure:

```csv
first_name,last_name,department,job_title
Michael,Scott,Education,Manager
Jim,Halpert,Education,Engineer
Pam,Beesly,Education,Engineer
```

**Key Points**:
- First row contains column headers
- Each subsequent row represents one user
- Columns: `first_name`, `last_name`, `department`, `job_title`
- No spaces after commas

### Step 2: Understand the Main Configuration (main.tf)

Review the `main.tf` file to understand how it works:

1. **Data Source for Domain**:
   ```hcl
   data "azuread_domains" "aad" {
     only_initial = true
   }
   ```
   - Retrieves the initial/primary domain name for your Azure AD tenant

2. **Local Values**:
   ```hcl
   locals {
     domain_name = data.azuread_domains.aad.domains.0.domain_name
     users = csvdecode(file("users.csv"))
   }
   ```
   - Extracts the domain name
   - Reads and decodes the CSV file into a list of objects

3. **User Creation**:
   - Uses `for_each` to iterate over users
   - Creates User Principal Name (UPN) in format: `<first_initial><last_name>@<domain>`
   - Generates password based on user data
   - Sets display name, department, and job title

### Step 3: Understand Group Configuration (group.tf)

Review the `group.tf` file:

1. **Group Creation**: Creates security groups
2. **Group Membership**: Uses `for_each` with filtering to add users to groups based on:
   - Department (e.g., "Education")
   - Job title (e.g., "Manager", "Engineer")

### Step 4: Plan the Initial Deployment

1. **Review the plan**:
   ```bash
   terraform plan
   ```

2. **Verify**:
   - 3 users will be created (Michael Scott, Jim Halpert, Pam Beesly)
   - 3 groups will be created (Education Department, Education - Managers, Education - Engineers)
   - Users will be assigned to appropriate groups

### Step 5: Apply the Initial Configuration

1. **Apply the configuration**:
   ```bash
   terraform apply
   ```

2. **Review the output**:
   - Domain name
   - Username list

3. **Verify in Azure Portal**:
   - Go to Azure AD → Users
   - Verify all 3 users are created
   - Go to Azure AD → Groups
   - Verify all 3 groups are created
   - Check group memberships

### Step 6: Add More Users to CSV

Edit `users.csv` and add more users. For example:

```csv
first_name,last_name,department,job_title
Michael,Scott,Education,Manager
Jim,Halpert,Education,Engineer
Pam,Beesly,Education,Engineer
Dwight,Schrute,Education,Sales Representative
Angela,Martin,Customer Success,Support Specialist
```

**Note**: We're adding:
- Dwight Schrute (Education department)
- Angela Martin (Customer Success department - new department)

### Step 7: Add User to Existing Group

To add a user (e.g., Dwight Schrute) to an existing group, you can:

**Option A**: Modify the group membership filter in `group.tf` to include the user based on criteria

**Option B**: Add a specific group membership resource. Add this to `group.tf`:

```hcl
# Add Dwight Schrute to Education Department group
resource "azuread_group_member" "dwight_education" {
  group_object_id  = azuread_group.engineering.id
  member_object_id = azuread_user.users["Dwight"].id
}
```

**Note**: The key `"Dwight"` matches the `for_each` key in `main.tf` which uses `user.first_name`.

### Step 8: Create Customer Success Group

Add a new group for Customer Success in `group.tf`:

```hcl
resource "azuread_group" "customer_success" {
  display_name     = "Customer Success Department"
  security_enabled = true
}
```

### Step 9: Add New User to Customer Success Group

Add group membership for Customer Success users in `group.tf`:

```hcl
resource "azuread_group_member" "customer_success" {
  for_each = { 
    for u in azuread_user.users : u.mail_nickname => u 
    if u.department == "Customer Success" 
  }

  group_object_id  = azuread_group.customer_success.id
  member_object_id = each.value.id
}
```

### Step 10: Plan and Apply Changes

1. **Review the plan**:
   ```bash
   terraform plan
   ```

2. **Verify**:
   - 2 new users will be created (Dwight Schrute, Angela Martin)
   - 1 new group will be created (Customer Success Department)
   - Dwight will be added to Education Department group
   - Angela will be added to Customer Success Department group

3. **Apply the changes**:
   ```bash
   terraform apply
   ```

### Step 11: Verify Results

1. **Check Terraform Output**:
   ```bash
   terraform output
   ```

2. **Verify in Azure Portal**:
   - **Users**: Go to Azure AD → Users
     - Verify all 5 users exist
     - Check user details (department, job title)
   
   - **Groups**: Go to Azure AD → Groups
     - Verify all 4 groups exist:
       - Education Department
       - Education - Managers
       - Education - Engineers
       - Customer Success Department
   
   - **Group Memberships**: Click on each group and verify members:
     - Education Department: Michael, Jim, Pam, Dwight
     - Education - Managers: Michael
     - Education - Engineers: Jim, Pam
     - Customer Success Department: Angela

3. **Test User Login** (Optional):
   - Try logging in with one of the created users
   - Use the generated password (users will be forced to change it)

### Step 12: Understanding Key Concepts

#### CSV Decoding
```hcl
csvdecode(file("users.csv"))
```
- Reads the CSV file and converts it to a list of objects
- Each row becomes an object with keys matching column headers

#### For Each with Filtering
```hcl
for_each = { 
  for u in azuread_user.users : u.mail_nickname => u 
  if u.department == "Education" 
}
```
- Iterates over users
- Filters based on condition (`department == "Education"`)
- Creates a map with `mail_nickname` as key

#### User Principal Name Generation
```hcl
format("%s%s@%s",
  substr(each.value.first_name,0,1),  # First letter of first name
  lower(each.value.last_name),        # Lowercase last name
  local.domain_name)                   # Domain name
```
- Example: "Michael Scott" → "mscott@yourdomain.onmicrosoft.com"

#### Password Generation
```hcl
format("%s%s%s!",
  lower(each.value.last_name),              # Lowercase last name
  substr(lower(each.value.first_name),0,1), # First letter of first name
  length(each.value.first_name)             # Length of first name
)
```
- Example: "Michael Scott" → "scottm7!"

## Troubleshooting

### Common Issues:

1. **CSV Parsing Errors**
   - **Error**: "Invalid CSV format"
   - **Solution**: Ensure CSV file has proper headers and no trailing commas
   - **Check**: Verify file encoding is UTF-8

2. **Domain Not Found**
   - **Error**: "No domains found"
   - **Solution**: Ensure `only_initial = true` or specify domain explicitly
   - **Check**: Verify Azure AD tenant has a verified domain

3. **User Already Exists**
   - **Error**: "User principal name already exists"
   - **Solution**: Modify UPN generation logic or use different users
   - **Check**: Verify no duplicate users in CSV

4. **Group Membership Errors**
   - **Error**: "Member not found"
   - **Solution**: Ensure users are created before group memberships
   - **Check**: Verify `depends_on` or implicit dependencies are correct

## Verification Checklist

- [ ] CSV file contains initial 3 users
- [ ] Initial plan shows 3 users and 3 groups
- [ ] Initial apply completed successfully
- [ ] Users verified in Azure Portal
- [ ] Groups verified in Azure Portal
- [ ] Group memberships verified
- [ ] Additional users added to CSV
- [ ] User added to existing group (Dwight to Education Department)
- [ ] New group created for Customer Success
- [ ] New user added to Customer Success group
- [ ] Final verification in Azure Portal completed

## Cleanup

When finished, destroy all resources:

```bash
terraform destroy
```

**Note**: This will delete all users and groups created by Terraform. Be careful in production environments!

## Key Concepts Learned

- **CSV Processing**: Reading and parsing CSV files with `csvdecode()`
- **Data Sources**: Querying Azure AD for domain information
- **For Each**: Creating multiple resources from a data structure
- **Filtering**: Using conditional logic in `for_each` expressions
- **Group Management**: Creating security groups and managing memberships
- **User Management**: Programmatically creating Azure AD users
- **String Functions**: Using `format()`, `substr()`, `lower()`, `length()`

## Files in this directory:

- `main.tf` - User creation from CSV file
- `group.tf` - Group creation and membership management
- `users.csv` - CSV file containing user data
- `versions.tf` - Provider version requirements
- `.gitignore` - Git ignore rules
- `README.md` - Assignment requirements
- `task.md` - This file

## References

- [Azure AD Provider Documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [Service Principal Client Secret Guide](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret)
- [Microsoft Graph API Guide](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/microsoft-graph)
- [Azure AD Domains Data Source](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains)

## Next Steps

After completing this task, consider:
- Adding more user attributes (office, phone, etc.)
- Creating dynamic groups based on user attributes
- Implementing user lifecycle management
- Adding conditional logic for different departments
- Creating a module for reusable user/group creation
- Adding output values for user UPNs and passwords
- Implementing password policies and complexity requirements

