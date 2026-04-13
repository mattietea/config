---
name: git-machete
description: "Stacked PRs and branch dependency management with git machete. Use when a PR is too large to review, when splitting work into reviewable pieces that build on each other, when creating dependent PR chains, or when rebasing a chain of branches. Also use when asked to 'break this up', 'this PR is too big', 'split this into smaller PRs', or anything involving stacked/dependent branches."
---

# Git Machete — Stacked PRs

Use `git machete` (aliased as `git m`) to manage stacked PRs — a chain of individually shippable branches where each builds on the one before it.

## When to Stack

Target 2-3 PRs per feature, each 200-500 lines. Stack for these reasons:

- **You're blocked on review.** PR 1 is out for review and you need to keep working. Stack PR 2 on top instead of waiting.
- **Different reviewers for different parts.** Backend doesn't need to review frontend code. Split where the reviewer changes.
- **Risk isolation.** A migration or schema change that should be independently revertable from the feature code that uses it.

Don't stack when the feature is under 500 lines, when the split would create PRs that don't make sense independently, or when the work is a single concern.

## How to Split

Each branch in the stack must be **individually shippable** — passing tests, no dead code, no half-built abstractions. A reviewer should be able to approve any PR without seeing what comes after it.

Common split patterns:

1. **Functional layers** — data model → API → UI
2. **Refactor then change** — cleanup in one PR, behavior change in the next
3. **Risk isolation** — migration separate from the code that uses it
4. **Generated/mechanical** — codegen, version bumps, lockfile updates separate from logic

Use `git m diff` and `git m log` to see what's unique to each branch when deciding where to cut.

## Workflow

### Build the tree

Use `git m add` to register branches as you create them:

```bash
git checkout -b feat/add-user-model
# make changes, commit
git m add

git checkout -b feat/user-api
# make changes, commit
git m add
```

Check the tree with `git m s`. To rearrange, use `git m edit` which opens `.git/machete`:

```
main
    feat/add-user-model
        feat/user-api
```

### Create stacked PRs

From each branch:

```bash
git m github create-pr
```

Each PR targets its parent branch and the description shows the full stack.

### Keep the stack in sync

```bash
git m traverse -H    # rebase, push, create/retarget PRs, slide out merged branches
```

This single command handles everything: rebases each branch onto its parent, pushes, creates GitHub PRs if missing, retargets PRs if the base changed, and offers to slide out merged branches.

For just the current branch without PR sync:

```bash
git m update         # rebase onto parent
```

## Quick Reference

| Command                                         | What it does                                       |
| ----------------------------------------------- | -------------------------------------------------- |
| `git m s`                                       | Show branch tree with sync status                  |
| `git m add`                                     | Add current branch to the tree under its parent    |
| `git m edit`                                    | Edit the full branch dependency file               |
| `git m discover`                                | Auto-detect tree from git history                  |
| `git m update`                                  | Rebase current branch onto its parent              |
| `git m traverse`                                | Walk entire tree — rebase and push each branch     |
| `git m slide-out`                               | Remove current branch, rebase children onto parent |
| `git m github create-pr`                        | Create PR targeting parent with stack info         |
| `git m github restack-pr`                       | Retarget PR and update descriptions after merge    |
| `git m github update-pr-descriptions --related` | Update stack info in all related PRs               |
| `git m diff`                                    | Show only this branch's changes vs fork point      |
| `git m log`                                     | Show only this branch's commits                    |
