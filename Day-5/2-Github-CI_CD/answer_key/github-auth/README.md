# Answer Key: GitHub Authentication on Linux

This directory contains helper scripts and resources for GitHub authentication on Linux.

## Files

- **`verify_github_auth.sh`** - Script to verify GitHub authentication is properly configured

## Usage

### Verify Authentication

Run the verification script to check your GitHub setup:

```bash
./verify_github_auth.sh
```

The script checks:
1. ✅ GitHub CLI installation
2. ✅ Authentication status
3. ✅ GitHub API access
4. ✅ Git configuration
5. ✅ Git credential helper
6. ✅ SSH keys (if configured)

### Quick Setup Commands

```bash
# Install GitHub CLI (Ubuntu/Debian)
sudo apt update
sudo apt install -y gh

# Login to GitHub
gh auth login

# Verify authentication
gh auth status

# Setup Git with GitHub
gh auth setup-git

# Configure Git user
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Test GitHub API
gh api user

# Clone a repository
gh repo clone username/repo
```

## Troubleshooting

### Authentication Issues

If authentication fails:

```bash
# Logout and re-authenticate
gh auth logout
gh auth login

# Check status
gh auth status

# Refresh token
gh auth refresh
```

### Git Configuration Issues

If Git operations fail:

```bash
# Setup Git credential helper
gh auth setup-git

# Verify Git config
git config --global --list

# Test Git operations
git clone https://github.com/username/repo.git
```

### SSH Issues

If SSH authentication fails:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Then add to: https://github.com/settings/keys

# Test SSH connection
ssh -T git@github.com
```

## Next Steps

After verifying authentication:

1. **Clone or create a repository**
2. **Set up GitHub Actions workflows**
3. **Configure repository secrets**
4. **Create CI/CD pipelines**

See the main guide: `../../github_authentication_linux_review.md`

