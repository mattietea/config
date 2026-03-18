---
name: notion
description: Search, read, and manage Notion pages, databases, and comments
---

# Notion

Use `mcporter` to interact with Notion. This avoids loading Notion's ~15 MCP tools into context permanently.

## Discovery

```bash
mcporter list notion --schema
```

## Usage

```bash
mcporter call notion.<tool_name> key:value key2:'string value'
```

## Common operations

```bash
# Search pages
mcporter call notion.notion-search query:'meeting notes'

# Read a page
mcporter call notion.notion-fetch pageId:'page-id-here'

# Create a page
mcporter call notion.notion-create-pages title:'New Page' parentId:'parent-id'

# Query a database
mcporter call notion.notion-query-data-sources databaseId:'db-id'

# Add a comment
mcporter call notion.notion-create-comment pageId:'page-id' body:'Comment text'

# Get users
mcporter call notion.notion-get-users
```

## Authentication

If you get a 401 error, run:

```bash
mcporter auth notion
```
