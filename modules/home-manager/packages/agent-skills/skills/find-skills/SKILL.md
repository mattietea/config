---
name: find-skills
description: "Discover and install agent skills via the Nix agent-skills module. Use when users ask 'how do I do X', 'find a skill for X', 'is there a skill that can...', or want to extend capabilities. Installs skills declaratively through flake inputs and agent-skills-nix, never via npx."
---

# Find Skills (Nix)

Discover skills at [skills.sh](https://skills.sh/) and install them declaratively through the Nix agent-skills module.

## Search for Skills

```bash
npx skills find [query]
```

Returns results like: `vercel-labs/agent-skills@react-best-practices`

Also browse [skills.sh](https://skills.sh/) for trending and popular skills.

## Install a Skill

Parse the search result format: `<owner>/<repo>@<skill-name>`.

### 1. Check if source exists

Look in `flake.nix` inputs and `modules/home-manager/packages/agent-skills/default.nix` sources.

Known sources already configured:

| Source name | Input              | Repo                              |
| ----------- | ------------------ | --------------------------------- |
| `anthropic` | `anthropic-skills` | `github:anthropics/skills`        |
| `vercel`    | `vercel-skills`    | `github:vercel-labs/agent-skills` |

### 2a. Source exists — just enable the skill

Add the skill name to `skills.enable` in `modules/home-manager/packages/agent-skills/default.nix`:

```nix
skills.enable = [
  "existing-skill"
  "new-skill"  # add here
];
```

### 2b. New source — add input + source + skill

**Add non-flake input** to `flake.nix`:

```nix
new-source = {
  url = "github:<owner>/<repo>";
  flake = false;
};
```

**Add source** to `agent-skills/default.nix`:

```nix
sources.new-source = {
  path = inputs.new-source;
  subdir = "skills";  # directory containing skill folders
};
```

**Add skill** to `skills.enable`:

```nix
skills.enable = [
  "new-skill"
];
```

Note: `subdir` is the path within the repo where skill directories live. Check the repo structure — most use `skills/`.

### 3. Apply

```bash
git add -A && switch
```

New flake inputs require `git add` before Nix can see them.

## When No Skills Are Found

1. Offer to help with the task directly
2. Suggest creating a local skill in `.claude/skills/<name>/SKILL.md` using the skill-creator skill
