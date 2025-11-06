## 💾 Terraform Module 3: Remote State Management with Azure Storage

This module is essential for security and team collaboration. It guides you through migrating your local state file (`terraform.tfstate`) to a secure Azure Blob Storage container.

### Prerequisites

1.  **Project Files:** You should have your `main.tf`, `variables.tf`, and `outputs.tf` files ready from the VM deployment module.
2.  **Azure Resources Created:** You must have already manually created the following resources using the Azure CLI:
    * A **Resource Group** (`$RESOURCE_GROUP_NAME`)
    * A **Storage Account** (`$STORAGE_ACCOUNT_NAME`)
    * A **Blob Container** (`$CONTAINER_NAME`)
3.  **Authentication:** Your Service Principal environment variables must be set in your current terminal session.

---

### Step 1: Create a `backend.tf` File

While you can put the backend configuration in `main.tf`, it is best practice to define it in a separate, dedicated file.

1.  **Create the file in your project directory:**
    ```bash
    touch backend.tf
    ```

2.  **Add the `backend` configuration:**
    Edit `backend.tf` and paste the following, making sure to replace the placeholder values with your actual resource names.

    ```terraform
    # backend.tf

    terraform {
      backend "azurerm" {
        # The Resource Group where the storage account resides
        resource_group_name  = "tfstate-day04" 
        
        # The globally unique name of your storage account
        storage_account_name = "day0412345" 
        
        # The name of the container inside the storage account
        container_name       = "tfstate"     
        
        # The name the state file will be saved as in the container
        key                  = "prod/linux-vm.tfstate" 
        
        # Note: We omit the access_key here and rely on your 
        # authenticated Azure CLI session (Service Principal) for access.
      }
    }
    ```

### Step 2: Remove Local State Configuration (Crucial!)

When you define a `backend` block in a configuration that previously used local state, Terraform will attempt to migrate the state when you run `init`.

Before migration, **you must ensure the `terraform` block in your `main.tf` file is clean.**

1.  **Open `main.tf`** and **REMOVE** the old `terraform` block completely:

    *(Old `main.tf` contents to remove:)*
    ```terraform
    # DELETE THIS BLOCK FROM main.tf
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.0"
        }
      }
    }
    ```

2.  **Move `required_providers`:** Now, open your new **`backend.tf`** file and ensure it contains the `required_providers` block from above.

    *(Your final `backend.tf` should now look like this:)*

    ```terraform
    # backend.tf - Final Content

    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.0"
        }
      }

      backend "azurerm" {
        resource_group_name  = "tfstate-day04" 
        storage_account_name = "day0412345" 
        container_name       = "tfstate"     
        key                  = "prod/linux-vm.tfstate" 
      }
    }
    ```

### Step 3: Run `terraform init` to Migrate State

The `init` command handles state migration automatically when it detects a change from a local backend to a remote backend.

1.  **Run the Initialization Command:**
    ```bash
    terraform init
    ```

2.  **Review the Migration Prompt:**
    Terraform will recognize the change and prompt you:
    ```
    Initializing the backend...
    
    Successfully configured the backend "azurerm"! Terraform will now attempt 
    to copy the current local state to the newly configured backend.
    
    Do you want to copy your current state to the new backend?
      The state will be saved to: azurerm.../prod/linux-vm.tfstate
    
    Enter 'yes' to copy the state:
    ```

3.  **Type `yes` to Confirm.**

#### **Key Outcome:**

Your local `terraform.tfstate` file is uploaded to the Azure Blob Storage container and is now locked for all future operations. Your project is now ready for collaborative development!

### Step 4: Verify the Remote State

1.  **Delete the local state file:** You can safely delete the local file (`terraform.tfstate` - **Warning: only do this after a successful migration!**)
    ```bash
    rm terraform.tfstate
    ```

2.  **Run a state list command:** Terraform must now retrieve the state from Azure to run this command. If it works, the migration was successful.

    ```bash
    terraform state list
    # Output should list your resources (e.g., azurerm_resource_group.rg_lesson)
    ```

---

The next important module in your curriculum should focus on managing secrets and references. Would you like to cover **Azure Key Vault integration** next?