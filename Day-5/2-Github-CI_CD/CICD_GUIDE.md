# CI/CD with GitHub Actions Guide

## GitHub Actions Pricing and Free Tier

### Can You Use GitHub Actions for Free?

**Yes!** GitHub Actions has a generous free tier:

#### Public Repositories
- ✅ **Unlimited** GitHub Actions minutes
- ✅ **Unlimited** storage
- ✅ **Unlimited** workflows
- ✅ **No credit card required**

#### Private Repositories (Free GitHub Account)
- ✅ **2,000 minutes/month** free
- ✅ **500 MB storage** free
- ✅ Additional minutes: $0.008 per minute (Linux)
- ✅ Additional storage: $0.008 per GB/month

#### Private Repositories (GitHub Pro/Team/Enterprise)
- ✅ **3,000 minutes/month** free (Pro)
- ✅ **10,000 minutes/month** free (Team)
- ✅ **50,000 minutes/month** free (Enterprise)

### Free Tier Details

**What counts toward minutes:**
- Workflow execution time
- Only Linux runners count toward free tier (Windows/macOS cost more)
- Idle time doesn't count

**Typical Terraform workflow usage:**
- Validation: ~1-2 minutes
- Plan: ~2-5 minutes
- Apply: ~5-15 minutes (depending on resources)

**Example monthly usage:**
- 50 PRs with validation + plan = ~150-350 minutes
- 10 deployments with apply = ~50-150 minutes
- **Total: ~200-500 minutes/month** (well within free tier!)

### When You Might Need to Pay

You'll only need to pay if:
- Using **private repositories** extensively (>2,000 minutes/month)
- Using **Windows/macOS runners** (costs more)
- Using **self-hosted runners** (free, but you manage infrastructure)
- Exceeding **storage limits** (artifacts, logs)

### Cost Estimation

**For learning/development:**
- Public repos: **$0** (completely free)
- Private repos: **$0** (likely within free tier)

**For small teams:**
- Private repos: **$0-10/month** (typically within free tier)

**For larger teams:**
- Consider GitHub Team ($4/user/month) for more minutes
- Or use public repos for open-source projects

### Recommendations for Students

1. **Use Public Repositories** - Completely free, unlimited minutes
2. **Use Private Repositories** - Free tier is usually sufficient for learning
3. **Monitor Usage** - Check Settings > Billing to see your usage
4. **Optimize Workflows** - Use `paths:` filters to avoid unnecessary runs

### Checking Your Usage

1. Go to repository **Settings** > **Actions** > **Usage**
2. Or go to your profile **Settings** > **Billing** > **Plans and usage**

**Screenshot Location**: `screenshots/29-actions-usage.png`
*[Screenshot should show: GitHub Actions usage page showing minutes used vs. free tier limit]*

---

## Prerequisites

1. **GitHub Repository**
   - Create a repository for your Terraform code (public or private)
   - Enable GitHub Actions (enabled by default)
   - **Note**: Public repos have unlimited free Actions minutes

2. **Azure Service Principal**
   Create a service principal for GitHub Actions:
   ```bash
   az ad sp create-for-rbac --name "github-actions-terraform" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

3. **GitHub Secrets**
   Add the following secrets to your GitHub repository:
   - `AZURE_CREDENTIALS`: Output from service principal creation
   - `ARM_CLIENT_ID`: Service principal client ID
   - `ARM_CLIENT_SECRET`: Service principal client secret
   - `ARM_SUBSCRIPTION_ID`: Azure subscription ID
   - `ARM_TENANT_ID`: Azure tenant ID

## Workflow Files

### 1. Validation Workflow (`terraform-validate.yml`)
- Runs on pull requests
- Checks formatting and validates configuration
- Comments on PR with results

### 2. Plan Workflow (`terraform-plan.yml`)
- Runs on pull requests to main
- Creates Terraform plan
- Posts plan as PR comment
- Stores plan artifact

### 3. Apply Workflow (`terraform-apply.yml`)
- Runs on push to main
- Applies Terraform changes
- Requires environment approval for production
- Stores outputs as artifacts

### 4. Destroy Workflow (`terraform-destroy.yml`)
- Manual workflow
- Allows selective environment destruction
- Requires environment approval

## Setting Up GitHub Environments

1. Go to repository Settings > Environments
2. Create environments: `dev`, `staging`, `production`
3. Configure protection rules:
   - Required reviewers for production
   - Deployment branches
   - Wait timer (optional)

## Secret Management

### Azure Credentials Format
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "..."
}
```

### Adding Secrets
1. Go to repository Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add each secret

## Best Practices

1. **Never commit secrets**
   - Use GitHub Secrets for all sensitive data
   - Use environment-specific secrets

2. **Use environment protection**
   - Require approvals for production
   - Limit who can approve deployments

3. **Plan before apply**
   - Always review plans before applying
   - Use PR comments to review changes

4. **Artifact management**
   - Store plans and outputs as artifacts
   - Set retention policies

5. **Error handling**
   - Use `continue-on-error` appropriately
   - Implement rollback procedures
   - Send notifications on failure

## Troubleshooting

### Authentication Issues
- Verify service principal has correct permissions
- Check secret values are correct
- Ensure service principal is not expired

### Backend Issues
- Verify backend configuration
- Check storage account access
- Ensure state locking is working

### Workflow Failures
- Check workflow logs
- Verify all required secrets are set
- Ensure Terraform version compatibility

## Using GitHub Actions

### Finding Public Actions

GitHub Actions Marketplace is where you can find thousands of pre-built actions:
- **URL**: https://github.com/marketplace?type=actions
- **Search**: Use the search bar to find actions for specific tools
- **Official Actions**: Look for actions maintained by the tool's official organization

### Official Terraform Action

GitHub provides an official Terraform action maintained by HashiCorp:

**Action**: `hashicorp/setup-terraform@v3`
**Marketplace**: https://github.com/marketplace/actions/hashicorp-setup-terraform
**Documentation**: https://github.com/hashicorp/setup-terraform

**Key Features:**
- Installs Terraform (specify version or use latest)
- Configures Terraform CLI
- Supports Terraform Cloud/Enterprise integration
- Automatic output formatting (masks sensitive values)
- Workspace support
- Outputs Terraform version for use in other steps

**Basic Usage:**
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.5.0
```

**With Output Masking (Recommended):**
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.5.0
    terraform_outputs: true  # Automatically masks sensitive outputs
```

**With Terraform Cloud:**
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.5.0
    terraform_wrapper: false
  env:
    TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
```

**Common Inputs:**
- `terraform_version` - Specific version (e.g., "1.5.0") or "latest"
- `terraform_wrapper` - Enable/disable wrapper script (default: true)
- `terraform_outputs` - Mask sensitive outputs in logs (default: false)
- `cli_config_credentials_token` - Token for Terraform Cloud/Enterprise

### Azure Login Action

For Azure authentication in GitHub Actions, use the official Azure action:

**Action**: `azure/login@v1`
**Marketplace**: https://github.com/marketplace/actions/azure-login
**Documentation**: https://github.com/Azure/login

**Usage:**
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
```

### Example: Complete Workflow with Official Actions

```yaml
name: Terraform Plan

on:
  pull_request:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        id: plan
        run: terraform plan -out=tfplan
        continue-on-error: true

      - name: Comment PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Plan 📖
            \`\`\`
            ${process.env.PLAN}
            \`\`\`
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
```

### Popular GitHub Actions for Terraform

1. **Setup Terraform** - `hashicorp/setup-terraform@v3`
   - Official HashiCorp action
   - Installs and configures Terraform

2. **Azure Login** - `azure/login@v1`
   - Official Microsoft action
   - Authenticates with Azure

3. **Checkout** - `actions/checkout@v4`
   - Official GitHub action
   - Checks out repository code

4. **GitHub Script** - `actions/github-script@v7`
   - Official GitHub action
   - Run JavaScript/TypeScript scripts with GitHub API

### How to Use Actions

**Action Syntax:**
```yaml
- name: Step Name
  uses: owner/action-name@version
  with:
    input1: value1
    input2: value2
  env:
    ENV_VAR: value
```

**Finding Action Versions:**
- Check the action's repository releases
- Use major version tags (e.g., `@v3`) for stability
- Use specific commit SHAs for exact versions

**Action Inputs:**
- Check the action's README for available inputs
- Look for `action.yml` or `action.yaml` in the repository
- Review the Marketplace page for documentation

