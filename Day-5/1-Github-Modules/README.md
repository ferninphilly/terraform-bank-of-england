# Day 5 - GitHub Modules

## Overview
Learn to publish and use Terraform modules from GitHub. This section focuses on publishing modules to GitHub, versioning, and using them from remote sources in your Terraform configurations.

## Prerequisites

Before starting, ensure you have:
- ✅ Completed GitHub authentication (Day 5, Step 1 - CI/CD section)
- ✅ GitHub CLI (`gh`) installed and authenticated
- ✅ Git configured with your GitHub credentials
- ✅ Access to the VM module from Day 4 (`Day-4/3-Review-Modules/answer_key_vm/`)

## Learning Path

### Task 1: Publish Module to GitHub
**File**: `publish_module_to_github_task.md`

**Essential first step** - Learn to publish Terraform modules to GitHub:
- Prepare module for GitHub publication
- Create GitHub repository for your module
- Structure module with proper documentation
- Publish module with version tags
- Use modules from GitHub in Terraform
- Understand module versioning and semantic versioning
- Best practices for module repositories

**You'll publish the VM module with alerts and networking from Day 4.**

### Task 2: Module Inheritance and Composition (Coming Next)

After publishing modules to GitHub, learn:
- Module inheritance patterns
- Composing modules together
- Variable replacement and defaults
- Cross-module communication
- Multi-tier application modules

## Learning Objectives
- ✅ Publish Terraform modules to GitHub
- ✅ Use modules from GitHub in Terraform configurations
- ✅ Understand module versioning and semantic versioning
- ✅ Create proper module documentation
- ✅ Structure modules for GitHub publication
- ✅ Create reusable modules with proper structure
- ✅ Implement module inheritance and composition
- ✅ Use variable replacement and defaults effectively
- ✅ Understand module versioning and dependencies
- ✅ Create module outputs for cross-module communication

## Task 1: Publish Module to GitHub

### Overview

In this task, you'll take the VM module with alerts and networking from Day 4 and publish it to GitHub as a reusable module. This demonstrates:

1. **Module Publication Workflow**
   - Preparing modules for GitHub
   - Creating GitHub repositories
   - Versioning and tagging

2. **Using Remote Modules**
   - Referencing modules from GitHub
   - Version pinning
   - Module updates

3. **Best Practices**
   - Module structure
   - Documentation
   - Versioning strategy

### What You'll Do

1. **Prepare the VM Module**
   - Review module structure
   - Add documentation
   - Create `.gitignore`

2. **Create GitHub Repository**
   - Use GitHub CLI to create repository
   - Initialize Git repository
   - Push module to GitHub

3. **Version and Release**
   - Create version tags
   - Create GitHub releases
   - Document changes

4. **Use Module from GitHub**
   - Reference module in Terraform
   - Initialize and use module
   - Test module functionality

### Key Concepts

- **Module Source Syntax**: `github.com/username/repo?ref=version`
- **Semantic Versioning**: Major.Minor.Patch (v1.0.0)
- **Module Structure**: README, variables, outputs, examples
- **Version Tags**: Git tags for module versions

### Deliverables

- ✅ GitHub repository with VM module
- ✅ Tagged release (v1.0.0)
- ✅ Comprehensive README.md
- ✅ Example usage in test configuration
- ✅ Understanding of module versioning

## Getting Started

1. **Start with Task 1**: Follow `publish_module_to_github_task.md`
2. **Publish your VM module** to GitHub
3. **Use the module** from GitHub in a test configuration
4. **Optional**: Publish the alerts module separately

## Resources

- [Module README Template](module_readme_template.md) - Template for module documentation
- [VM Module Source](../Day-4/3-Review-Modules/answer_key_vm/) - Source module to publish
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Terraform Module Sources](https://www.terraform.io/docs/language/modules/sources.html)

## Next Steps

After completing Task 1:
- Publish additional modules
- Create module examples
- Set up module testing
- Explore module composition (Task 2)

