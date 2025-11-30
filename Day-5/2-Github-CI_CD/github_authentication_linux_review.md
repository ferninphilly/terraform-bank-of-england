# Step-by-Step Guide: GitHub Authentication on Linux

This comprehensive guide walks you through authenticating with GitHub on a Linux machine using the GitHub CLI (`gh`). This is essential for working with GitHub Actions, managing repositories, and automating workflows.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Understanding GitHub Authentication Methods](#understanding-github-authentication-methods)
3. [Step 1: Install GitHub CLI](#step-1-install-github-cli)
4. [Step 2: Verify Installation](#step-2-verify-installation)
5. [Step 3: Log in to GitHub](#step-3-log-in-to-github)
6. [Step 4: Understand Authentication Methods](#step-4-understand-authentication-methods)
7. [Step 5: Verify Authentication](#step-5-verify-authentication)
8. [Step 6: Configure Git with GitHub](#step-6-configure-git-with-github)
9. [Step 7: Set Up SSH Keys (Optional but Recommended)](#step-7-set-up-ssh-keys-optional-but-recommended)
10. [Step 8: Create a Personal Access Token (PAT)](#step-8-create-a-personal-access-token-pat)
11. [Step 9: Use PAT for Authentication](#step-9-use-pat-for-authentication)
12. [Step 10: Configure Git Credentials](#step-10-configure-git-credentials)
13. [Troubleshooting](#troubleshooting)
14. [Security Best Practices](#security-best-practices)

---

## Prerequisites

Before starting, ensure you have:
- A Linux machine (Ubuntu, Debian, RHEL, CentOS, etc.)
- A GitHub account (create one at https://github.com if needed)
- Administrative/sudo access to install software
- Internet connectivity
- A web browser (for authentication)

---

## Understanding GitHub Authentication Methods

GitHub supports several authentication methods:

### 1. **GitHub CLI (`gh`) - Recommended**
- Official GitHub command-line tool
- Handles authentication automatically
- Supports multiple authentication methods
- **This guide focuses on this method**

### 2. **Personal Access Token (PAT)**
- Token-based authentication
- Good for CI/CD and automation
- Can be scoped to specific permissions
- Works with Git and API calls

### 3. **SSH Keys**
- Key-based authentication
- Best for Git operations
- More secure than HTTPS
- Recommended for frequent use

### 4. **OAuth Apps**
- For third-party integrations
- More complex setup
- Used by applications, not individuals

---

## Step 1: Install GitHub CLI

The GitHub CLI (`gh`) is the official command-line tool for GitHub. It simplifies authentication and GitHub operations.

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y curl

# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Update package list again
sudo apt update

# Install GitHub CLI
sudo apt install -y gh
```

### RHEL/CentOS/Fedora

```bash
# Install prerequisites
sudo dnf install -y curl

# Add GitHub CLI repository
sudo dnf install -y 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# Install GitHub CLI
sudo dnf install -y gh
```

### Alternative: Using Package Manager (if available)

```bash
# Ubuntu/Debian (if available in default repos)
sudo apt install -y gh

# Fedora
sudo dnf install -y gh
```

### Manual Installation (if package manager doesn't work)

```bash
# Download latest release
curl -s https://api.github.com/repos/cli/cli/releases/latest | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4 | wget -qi -

# Extract and install
tar -xzf gh_*_linux_amd64.tar.gz
sudo mv gh_*_linux_amd64/bin/gh /usr/local/bin/
rm -rf gh_*_linux_amd64*
```

---

## Step 2: Verify Installation

After installation, verify that `gh` is installed correctly:

```bash
# Check version
gh --version

# Expected output:
# gh version 2.x.x (YYYY-MM-DD)
# https://github.com/cli/cli/releases/tag/v2.x.x
```

**If you see an error:**
- Ensure the installation completed successfully
- Check that `/usr/local/bin` or the installation directory is in your PATH
- Try logging out and back in, or restart your terminal

---

## Step 3: Log in to GitHub

The GitHub CLI provides multiple ways to authenticate. The easiest is using a web browser.

### Method 1: Browser Authentication (Recommended for First-Time Setup)

```bash
# Start login process
gh auth login
```

**You'll be prompted with several questions:**

1. **What account do you want to log into?**
   ```
   ? What account do you want to log into? GitHub.com
   ```
   - Select `GitHub.com` (or `GitHub Enterprise Server` if using enterprise)

2. **What is your preferred protocol for Git operations?**
   ```
   ? What is your preferred protocol for Git operations? HTTPS
   ```
   - **HTTPS**: Easier setup, works everywhere
   - **SSH**: More secure, requires SSH key setup (we'll cover this later)
   - For now, choose **HTTPS**

3. **Authenticate Git with your GitHub credentials?**
   ```
   ? Authenticate Git with your GitHub credentials? Yes
   ```
   - Choose **Yes** to configure Git automatically

4. **How would you like to authenticate GitHub CLI?**
   ```
   ? How would you like to authenticate GitHub CLI? Login with a web browser
   ```
   - Choose **Login with a web browser**

5. **Paste your authentication code:**
   ```
   ! First copy your one-time code: XXXX-XXXX
   Press Enter to open github.com in your browser...
   ```
   - Copy the code shown (e.g., `XXXX-XXXX`)
   - Press Enter to open your browser
   - If browser doesn't open, visit: https://github.com/login/device
   - Paste the code and authorize the application

6. **Success!**
   ```
   ✓ Authentication complete. Press q to exit
   ```

### Method 2: Token Authentication (For CI/CD or Automation)

If you already have a Personal Access Token (PAT):

```bash
# Login with token
gh auth login --with-token < token.txt

# Or pipe directly
echo "your_token_here" | gh auth login --with-token
```

**Note:** We'll cover creating PATs in Step 8.

### Method 3: SSH Key Authentication

If you have SSH keys set up:

```bash
# Login with SSH
gh auth login --git-protocol ssh
```

---

## Step 4: Understand Authentication Methods

### What Happens During Authentication?

When you run `gh auth login`, the CLI:

1. **Generates a one-time code** - Unique code valid for a few minutes
2. **Opens your browser** - Directs you to GitHub's authorization page
3. **You authorize the CLI** - GitHub associates the CLI with your account
4. **Stores credentials** - Saves authentication token securely on your machine
5. **Configures Git** - Sets up Git to use your GitHub credentials

### Where Are Credentials Stored?

GitHub CLI stores credentials in:
- **Linux**: `~/.config/gh/` directory
- **Credentials file**: `~/.config/gh/hosts.yml`
- **Git credentials**: `~/.gitconfig` (if you chose to authenticate Git)

**Important:** Never share these files or commit them to version control!

---

## Step 5: Verify Authentication

After logging in, verify that authentication worked:

```bash
# Check authentication status
gh auth status

# Expected output:
# ✓ Logged in to github.com as YOUR_USERNAME (github.com)
# ✓ Git operations for github.com configured to use HTTPS protocol
# ✓ Token: ********************
```

**Test GitHub API access:**

```bash
# View your GitHub profile
gh api user

# List your repositories
gh repo list

# View current repository (if in a git repo)
gh repo view
```

**If you see errors:**
- Ensure you completed the browser authentication
- Check your internet connection
- Verify your GitHub account is active

---

## Step 6: Configure Git with GitHub

Even if you chose "Yes" during `gh auth login`, you may want to configure Git manually:

### Set Git User Information

```bash
# Set your GitHub username
git config --global user.name "YOUR_GITHUB_USERNAME"

# Set your email (use the email associated with your GitHub account)
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global --list
```

### Configure Git Credential Helper

GitHub CLI can act as a credential helper for Git:

```bash
# Configure Git to use GitHub CLI for authentication
gh auth setup-git

# Verify
git config --global --get credential.helper
```

**This allows Git commands** (`git clone`, `git push`, etc.) to automatically use your GitHub credentials.

---

## Step 7: Set Up SSH Keys (Optional but Recommended)

SSH keys provide a more secure way to authenticate with GitHub, especially for frequent Git operations.

### Generate SSH Key

```bash
# Generate a new SSH key (replace with your GitHub email)
ssh-keygen -t ed25519 -C "your.email@example.com"

# If ed25519 is not supported, use RSA:
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# When prompted:
# - Press Enter to accept default file location (~/.ssh/id_ed25519)
# - Enter a passphrase (recommended) or press Enter for no passphrase
```

### Add SSH Key to SSH Agent

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# If you used RSA:
ssh-add ~/.ssh/id_rsa
```

### Add SSH Key to GitHub

```bash
# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub

# Or display it
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard  # Linux with xclip
# Or
cat ~/.ssh/id_ed25519.pub  # Then manually copy
```

**Add to GitHub:**
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Give it a title (e.g., "My Linux Machine")
4. Paste your public key
5. Click "Add SSH key"

### Test SSH Connection

```bash
# Test SSH connection to GitHub
ssh -T git@github.com

# Expected output:
# Hi YOUR_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

### Configure Git to Use SSH

```bash
# Set Git to use SSH for GitHub
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Or configure GitHub CLI to use SSH
gh auth login --git-protocol ssh
```

---

## Step 8: Create a Personal Access Token (PAT)

Personal Access Tokens are useful for:
- CI/CD pipelines
- API access
- Automation scripts
- When you can't use browser authentication

### Create PAT via GitHub CLI

```bash
# Create a token interactively
gh auth token

# This will show your current token, or you can create a new one via web
```

### Create PAT via GitHub Website

1. **Go to GitHub Settings:**
   - Visit: https://github.com/settings/tokens
   - Or: GitHub.com → Your Profile → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token:**
   - Click "Generate new token" → "Generate new token (classic)"
   - Give it a descriptive name (e.g., "Terraform CI/CD")
   - Set expiration (recommended: 90 days or custom)

3. **Select Scopes (Permissions):**
   For Terraform and CI/CD, you typically need:
   - ✅ `repo` - Full control of private repositories
   - ✅ `workflow` - Update GitHub Action workflows
   - ✅ `write:packages` - Upload packages (if using GitHub Packages)
   - ✅ `read:org` - Read org and team membership (if in organizations)

4. **Generate Token:**
   - Click "Generate token"
   - **IMPORTANT:** Copy the token immediately! You won't be able to see it again.
   - Store it securely (password manager, secret management tool)

### Fine-Grained Personal Access Tokens (Beta)

GitHub also offers fine-grained tokens with more specific permissions:

1. Go to: https://github.com/settings/tokens?type=beta
2. Click "Generate new token"
3. Configure repository access and permissions
4. Generate and save the token

---

## Step 9: Use PAT for Authentication

### Login with PAT

```bash
# Method 1: Interactive (will prompt for token)
gh auth login --with-token

# Then paste your token and press Enter

# Method 2: From file
echo "your_token_here" | gh auth login --with-token

# Method 3: From environment variable
export GITHUB_TOKEN="your_token_here"
gh auth login --with-token <<< "$GITHUB_TOKEN"
```

### Use PAT with Git

```bash
# Configure Git to use token for HTTPS
git config --global credential.helper store

# When you push/pull, use token as password:
# Username: YOUR_GITHUB_USERNAME
# Password: YOUR_PERSONAL_ACCESS_TOKEN
```

**Or use token in URL (less secure, not recommended):**
```bash
git clone https://YOUR_TOKEN@github.com/username/repo.git
```

---

## Step 10: Configure Git Credentials

### Using GitHub CLI Credential Helper

```bash
# Set up Git credential helper (already done if you chose "Yes" during login)
gh auth setup-git

# This configures Git to use GitHub CLI for authentication
```

### Manual Git Credential Configuration

```bash
# Store credentials in Git config (less secure)
git config --global credential.helper store

# Use credential cache (credentials stored in memory, cleared on logout)
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'  # 1 hour timeout

# Use credential manager (if installed)
git config --global credential.helper manager-core
```

### Test Git Operations

```bash
# Clone a repository (will prompt for credentials if not configured)
git clone https://github.com/username/repo.git

# Push changes (will use stored credentials)
git push origin main

# Pull changes
git pull origin main
```

---

## Troubleshooting

### Issue: "gh: command not found"

**Solution:**
```bash
# Verify installation
which gh

# If not found, check PATH
echo $PATH

# Reinstall or add to PATH
export PATH=$PATH:/usr/local/bin
```

### Issue: "Authentication failed" or "Bad credentials"

**Solutions:**
1. **Verify your GitHub account is active:**
   ```bash
   gh auth status
   ```

2. **Re-authenticate:**
   ```bash
   gh auth logout
   gh auth login
   ```

3. **Check token expiration:**
   - If using PAT, verify it hasn't expired
   - Create a new token if needed

4. **Verify internet connectivity:**
   ```bash
   ping github.com
   ```

### Issue: "Permission denied (publickey)" when using SSH

**Solutions:**
1. **Verify SSH key is added to GitHub:**
   - Check: https://github.com/settings/keys
   - Ensure your public key is listed

2. **Test SSH connection:**
   ```bash
   ssh -T git@github.com
   ```

3. **Add SSH key to agent:**
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

4. **Check SSH key permissions:**
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

### Issue: Git operations asking for password repeatedly

**Solutions:**
1. **Set up credential helper:**
   ```bash
   gh auth setup-git
   ```

2. **Use SSH instead of HTTPS:**
   ```bash
   git remote set-url origin git@github.com:username/repo.git
   ```

3. **Store credentials:**
   ```bash
   git config --global credential.helper store
   # Next time you enter credentials, they'll be saved
   ```

### Issue: "Repository not found" when it should exist

**Solutions:**
1. **Verify authentication:**
   ```bash
   gh auth status
   ```

2. **Check repository access:**
   ```bash
   gh repo view username/repo
   ```

3. **Verify you have access to the repository:**
   - Check GitHub website
   - Ensure you're a collaborator or have access

### Issue: GitHub CLI not opening browser

**Solutions:**
1. **Manually visit the URL:**
   - Copy the code from terminal
   - Visit: https://github.com/login/device
   - Enter the code

2. **Use token authentication instead:**
   ```bash
   gh auth login --with-token
   ```

### Issue: "Token expired" or "Token invalid"

**Solutions:**
1. **Check token expiration:**
   - Go to: https://github.com/settings/tokens
   - Verify token hasn't expired

2. **Create new token:**
   - Generate a new PAT
   - Update authentication

3. **Re-authenticate:**
   ```bash
   gh auth logout
   gh auth login
   ```

---

## Security Best Practices

### 1. **Use SSH Keys for Git Operations**
- More secure than HTTPS with passwords
- No need to store passwords
- Better for frequent operations

### 2. **Protect Personal Access Tokens**
- Never commit tokens to version control
- Use environment variables or secret management
- Set appropriate expiration dates
- Use fine-grained tokens with minimal permissions

### 3. **Rotate Credentials Regularly**
- Change SSH keys periodically
- Regenerate PATs every 90 days (or as per policy)
- Revoke unused tokens

### 4. **Use Least Privilege Principle**
- Only grant necessary permissions to tokens
- Use fine-grained tokens when possible
- Review token permissions regularly

### 5. **Secure Credential Storage**
- Never share `~/.config/gh/` directory
- Protect SSH private keys (chmod 600)
- Use passphrases for SSH keys
- Store tokens in secure password managers

### 6. **Monitor Token Usage**
- Regularly review active tokens: https://github.com/settings/tokens
- Revoke unused or compromised tokens immediately
- Enable two-factor authentication (2FA) on GitHub account

### 7. **Use GitHub CLI Credential Helper**
- Let GitHub CLI manage credentials
- Avoid storing credentials in plain text
- Use `gh auth setup-git` for automatic configuration

### 8. **For CI/CD Pipelines**
- Use GitHub Actions secrets for tokens
- Never hardcode credentials in workflows
- Use repository secrets or organization secrets
- Rotate CI/CD tokens regularly

---

## Quick Reference Commands

```bash
# Install GitHub CLI
# Ubuntu/Debian: sudo apt install gh
# RHEL/Fedora: sudo dnf install gh

# Login
gh auth login

# Check status
gh auth status

# Logout
gh auth logout

# Refresh token
gh auth refresh

# Setup Git
gh auth setup-git

# View current user
gh api user

# List repositories
gh repo list

# Clone repository
gh repo clone username/repo

# Create repository
gh repo create

# View repository
gh repo view username/repo
```

---

## Next Steps

Now that you're authenticated with GitHub, you can:

1. **Clone and work with repositories**
2. **Set up GitHub Actions workflows** (covered in next task)
3. **Create and manage repositories**
4. **Work with GitHub API**
5. **Set up CI/CD pipelines**

**Proceed to the next task:** Setting up GitHub Actions for Terraform CI/CD

---

## Summary

In this guide, you learned:
- ✅ How to install GitHub CLI (`gh`) on Linux
- ✅ How to authenticate with GitHub using browser or token
- ✅ How to configure Git with GitHub credentials
- ✅ How to set up SSH keys for secure authentication
- ✅ How to create and use Personal Access Tokens
- ✅ How to troubleshoot common authentication issues
- ✅ Security best practices for GitHub credentials

You're now ready to work with GitHub repositories and set up CI/CD pipelines!

