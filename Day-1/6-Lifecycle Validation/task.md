# Task for step-6 - Lifecycle Rules

This module focuses on understanding and implementing Terraform lifecycle rules to control resource creation, updates, and destruction.

## Learning Objectives

Using the resources created earlier, implement the lifecycle rules as below:

- **create_before_destroy lifecycle** in the storage account and test it by updating the name of storage account. The newer resource should be created first and then the existing resource should be destroyed.
- **prevent_destroy lifecycle** in the storage account and update the storage account name and apply the changes. What did you observe?
- **ignore_changes lifecycle** in the resource group and update the resource group name, apply the changes, what did you observe?
- **Create a custom condition** that prevents the creation of resources in the location "canada central". It should throw an error if we have used "canada central" as the resource location.

## 📋 Learning Resources

### Option 1: Step-by-Step Tutorial (Recommended for Beginners)

**👉 See [LIFECYCLE.md](./LIFECYCLE.md) for comprehensive step-by-step instructions on implementing lifecycle rules.**

The LIFECYCLE.md file contains:
- Complete explanation of all lifecycle rules
- 8 detailed exercises with step-by-step instructions
- Hands-on practice for each lifecycle rule
- Testing scenarios to verify behavior
- Real-world use cases and examples
- Common mistakes and how to avoid them

### Option 2: Challenge-Based Exercises (For Self-Directed Learning)

**👉 See [EXERCISE.md](./EXERCISE.md) for challenge-based exercises that require you to figure out the implementation.**

The EXERCISE.md file contains:
- 9 challenge exercises covering all lifecycle rules
- Requirements and expected outcomes for each exercise
- Verification steps to confirm your implementation
- Questions to answer and concepts to understand
- Real-world scenario challenges
- Notes section for documenting your findings

## Quick Reference

### Lifecycle Rules Covered:
1. **`create_before_destroy`** - Minimize downtime during updates
2. **`prevent_destroy`** - Protect critical resources
3. **`ignore_changes`** - Prevent configuration drift
4. **`replace_triggered_by`** - Force replacement on dependency changes
5. **`precondition`** - Validate before resource creation
6. **`postcondition`** - Validate after resource creation

## Files in this directory:

- `main.tf` - Main Terraform configuration with resources
- `variables.tf` - Variable definitions
- `LIFECYCLE.md` - Step-by-step tutorial guide (for beginners)
- `EXERCISE.md` - Challenge-based exercises (for self-directed learning)
- `task.md` - This file
- `backend.tf` - Backend configuration
- `provider.tf` - Provider configuration
- `local.tf` - Local values
- `output.tf` - Output definitions

## Quick Start

**Choose your learning path:**

**Path 1 - Step-by-Step (Recommended):**
1. Review the lifecycle examples in `main.tf`
2. Follow the exercises in `LIFECYCLE.md` step-by-step
3. Test each lifecycle rule to understand its behavior
4. Complete the verification checklist

**Path 2 - Challenge-Based:**
1. Review the lifecycle examples in `main.tf`
2. Work through the challenges in `EXERCISE.md`
3. Figure out the implementation yourself
4. Verify your solutions meet the requirements
5. Document your findings in the notes section
