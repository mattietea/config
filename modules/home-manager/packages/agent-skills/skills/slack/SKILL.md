---
name: slack
description: Read and send Slack messages, search channels, and manage canvases
---

# Slack

Use `mcporter` to interact with Slack. This avoids loading Slack's ~12 MCP tools into context permanently.

## Discovery

```bash
mcporter list slack --schema
```

## Usage

```bash
mcporter call slack.<tool_name> key:value key2:'string value'
```

## Common operations

```bash
# Read a channel
mcporter call slack.slack_read_channel channelName:'general' limit:10

# Send a message
mcporter call slack.slack_send_message channelName:'general' text:'Hello team!'

# Search messages
mcporter call slack.slack_search_public query:'deployment issue'

# Read a thread
mcporter call slack.slack_read_thread channelName:'general' threadTs:'1234567890.123456'

# Search channels
mcporter call slack.slack_search_channels query:'engineering'

# Search users
mcporter call slack.slack_search_users query:'matt'
```

## Authentication

If you get a 401 error, run:

```bash
mcporter auth slack
```
