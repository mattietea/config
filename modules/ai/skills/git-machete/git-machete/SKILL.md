---
name: git-machete
description: "Stacked PRs and branch dependency management with git machete. Use when splitting large PRs into stacked branches, creating dependent PR chains, rebasing branch stacks, or managing branch hierarchies. Triggers: 'stack PRs', 'split this PR', 'stacked branches', 'dependent PRs', 'branch dependencies', 'rebase stack'."
---

# Git Machete — Stacked PRs

Use `git machete` (aliased as `git m`) to manage branch dependency trees and stacked PRs.

## When to Use

- Splitting a large PR into smaller, reviewable stacked PRs
- Creating a chain of dependent branches that build on each other
- Keeping a stack of branches in sync after upstream changes
- Creating GitHub PRs that show their position in a stack

## Core Workflow: Splitting a Large PR into a Stack

### 1. Plan the split

Before touching git, identify logical chunks of the work. Each chunk becomes a branch. Order matters — later branches depend on earlier ones.

### 2. Create the branch stack

```bash
# Start from main
git checkout main

# Create first branch with the base changes
git checkout -b stack/part-1
# Make changes, commit

# Create second branch on top of first
git checkout -b stack/part-2
# Make changes, commit

# And so on
git checkout -b stack/part-3
```

### 3. Define the dependency tree

```bash
git m edit
```

This opens `.git/machete`. Define the tree with indentation:

```
main
    stack/part-1
        stack/part-2
            stack/part-3
```

Or auto-discover from current branch structure:

```bash
git m discover
```

### 4. Check the stack status

```bash
git m s
```

Shows sync status — green means in sync, red means needs rebase.

### 5. Create stacked PRs

```bash
# From each branch in the stack:
git m github create-pr
```

Each PR targets its parent branch (not main), and the description includes the full stack visualization.

### 6. Keep the stack in sync

After making changes to an earlier branch:

```bash
# Rebase all downstream branches
git m traverse
```

Or update just the current branch from its parent:

```bash
git m update
```

Then update all PR descriptions to reflect current state:

```bash
git m github update-pr-descriptions --related
```

### 7. After a PR merges

When a PR in the stack gets merged:

```bash
# Slide out the merged branch and rebase its children onto its parent
git m slide-out

# Update PR targets
git m github restack-pr
```

## Quick Reference

| Command                                         | What it does                                       |
| ----------------------------------------------- | -------------------------------------------------- |
| `git m s`                                       | Show branch tree with sync status                  |
| `git m edit`                                    | Edit the branch dependency file                    |
| `git m discover`                                | Auto-detect branch tree from git history           |
| `git m update`                                  | Rebase current branch onto its parent              |
| `git m traverse`                                | Walk entire tree, rebase and push each branch      |
| `git m slide-out`                               | Remove current branch, rebase children onto parent |
| `git m github create-pr`                        | Create PR targeting parent branch with stack info  |
| `git m github restack-pr`                       | Retarget PR + update descriptions after rebase     |
| `git m github update-pr-descriptions --related` | Update stack info in all related PRs               |
| `git m diff`                                    | Show only this branch's changes (vs fork point)    |
| `git m log`                                     | Show only this branch's commits                    |

## With Worktrees

Git machete works with worktrees. The `.git/machete` file is shared across all worktrees. When `traverse` encounters a branch checked out in another worktree, it operates in the current worktree (configured via `stay-in-the-current-worktree`).

## Tips

- Branch names in a stack should share a prefix (e.g., `stack/auth-model`, `stack/auth-api`, `stack/auth-ui`)
- Use `git m anno` to add custom annotations to branches (shown in `status`)
- After squash-merging a PR, machete detects it and marks the branch as merged
- Use `-U` flag with `create-pr`, `restack-pr`, or `retarget-pr` to auto-update all related PR descriptions
