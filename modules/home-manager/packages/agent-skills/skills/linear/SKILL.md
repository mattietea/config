---
name: linear
description: Interact with Linear for issue tracking, project management, and team workflows
---

# Linear

Use `mcporter` to interact with Linear. This avoids loading Linear's ~30 MCP tools into context permanently.

## Discovery

```bash
mcporter list linear --schema
```

## Usage

```bash
mcporter call linear.<tool_name> key:value key2:'string value'
```

## Common operations

```bash
# List issues assigned to me
mcporter call linear.list_issues assigneeId:me

# Get issue details
mcporter call linear.get_issue issueId:ENG-123

# Create an issue
mcporter call linear.save_issue teamId:TEAM-ID title:'Fix the bug' description:'Details here'

# Add a comment
mcporter call linear.save_comment issueId:ENG-123 body:'Looks good!'

# Search issues
mcporter call linear.list_issues query:'search term'
```

## Authentication

If you get a 401 error, run:

```bash
mcporter auth linear
```
