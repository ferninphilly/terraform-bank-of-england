## 📖 Terraform Core Workflow: Init, Plan, and Apply

This guide explains the fundamental three-step workflow of Terraform, which allows you to safely and predictably manage infrastructure as code (IaC).

---

### The Terraform Workflow: I-P-A

The Terraform workflow is non-destructive and requires explicit confirmation before any changes are made. This process ensures safety, repeatability, and transparency.

| Command | Phase | Description |
| :--- | :--- | :--- |
| `terraform init` | **Initialization** (Setup) | Prepares the working directory, downloading providers and setting up the state. |
| `terraform plan` | **Planning** (Review) | Determines what actions are *required* to reach the desired state defined in your code. |
| `terraform apply` | **Application** (Action) | Executes the planned actions to create, update, or delete real infrastructure. |

---

### 1. `terraform init` (Initialization)

The `init` command is the **first command you must run** in any new or existing Terraform directory. It is a setup command that doesn't touch your cloud infrastructure.

#### **What it Does:**

* **Downloads Providers:** Reads the `required_providers` block in your configuration and downloads the necessary plugin binaries (e.g., the `azurerm` provider) so Terraform can communicate with your cloud (Azure).
Think of this as similar to `pip install -r requirements.txt` where the `requirements.txt` is your configuration provider block. It will also import any modules you need if they are externally hosted (or- if you're a `nodejs` type it's a `yarn install` where the configuration provider is the `package.json`)
* **Sets Up Backend:** Configures and initializes the **state backend** (where Terraform stores the mapping between your code and your real resources). By default, this is a local file (`terraform.tfstate`).
You will want to keep the `terraform.tfstate` in your `.gitignore` file. Think of this like `package-lock.json` if you are developing in `node.js`
* **Initializes Modules:** If your configuration uses remote modules, it downloads their code. 

#### **Key Outcome:**
It creates the hidden `.terraform/` directory, which holds all the necessary binaries and setup files.

```bash
# Must be run once for every new project or provider change
terraform init 

# Example Output:
# Terraform has been successfully initialized!

### 2. `terraform plan` (Planning)

The `plan` command is the **safety net** of the Terraform workflow. It is read-only and is designed to show you exactly what will happen before you commit any changes.

#### What it Does:

1.  **Refreshes State:** Queries your cloud environment (Azure) for the current state of all resources Terraform manages.
2.  **Compares States:** Compares the **current state** (from the cloud) with the **desired state** (from your `.tf` files).
3.  **Generates Execution Plan:** Determines the minimal set of actions (create, update, or destroy) needed to make the current state match the desired state. 

#### How to Read the Plan Output:

The plan output uses clear symbols to indicate the action for each resource:

| Symbol | Action | Meaning |
| :--- | :--- | :--- |
| **`+`** | **Create** | The resource does not exist and will be **created**. |
| **`~`** | **Update** | The resource exists, but one or more properties will be **modified** in place. |
| **`-`** | **Destroy** | The resource exists, but it is no longer defined in the code, so it will be **deleted**. |
| **`-/>`** | **Destroy and Create** | The resource must be fully destroyed and then re-created because a change was made to an immutable property. |

#### Key Outcomes:
The plan ends with a summary showing the exact count of actions:

```bash
# Example Plan Summary
Plan: 8 to add, 0 to change, 0 to destroy.

# Run plan before every apply to ensure safety
terraform plan

### 3. `terraform apply` (Application)

The `apply` command executes the changes defined in the execution plan, making real modifications to your cloud infrastructure. This is the **action** phase of the workflow.

#### What it Does:

1.  **Final Review:** By default, Terraform displays the generated plan one last time and requires explicit user confirmation.
2.  **Executes Changes:** It uses the provider binary (downloaded during `init`) and your authentication credentials (set in your environment) to communicate directly with the Azure API and fulfill the execution plan (creating, modifying, or destroying resources).
3.  **Updates State:** As resources are created or modified, Terraform immediately updates the `terraform.tfstate` file, recording the live attributes (IP addresses, resource IDs, connection details) of the managed infrastructure. 

#### Authorizing the Apply:

After reviewing the plan, you must type `yes` to authorize the action. This mandatory confirmation prevents accidental or premature deployments.

```bash
# Run apply to commit the changes
terraform apply

# ... Plan displayed ...

Enter a value: yes