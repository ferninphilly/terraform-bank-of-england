# CI/CD with GitHub Actions Guide

## Prerequisites

1. **GitHub Repository**
   - Create a repository for your Terraform code
   - Enable GitHub Actions

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

## Advanced Features

### Cost Estimation
Add cost estimation using Infracost:
```yaml
- name: Infracost
  uses: infracost/actions/setup@v1
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}
```

### Security Scanning
Add security scanning:
```yaml
- name: Run Checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: .
```

### Notifications
Add Slack notifications:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Terraform deployment completed'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

