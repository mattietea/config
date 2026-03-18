---
name: datadog
description: Query Datadog for logs, metrics, monitors, dashboards, incidents, and APM data
---

# Datadog

Use `mcporter` to interact with Datadog. This avoids loading Datadog's ~15 MCP tools into context permanently.

## Discovery

```bash
mcporter list datadog --schema
```

## Usage

```bash
mcporter call datadog.<tool_name> key:value key2:'string value'
```

## Common operations

```bash
# Search logs
mcporter call datadog.search_datadog_logs query:'service:api status:error' timeframe:'1h'

# Get a metric
mcporter call datadog.get_datadog_metric metric:'system.cpu.user'

# Search monitors
mcporter call datadog.search_datadog_monitors query:'tag:production'

# Search dashboards
mcporter call datadog.search_datadog_dashboards query:'api latency'

# Search incidents
mcporter call datadog.search_datadog_incidents query:'severity:SEV-1'

# Analyze logs
mcporter call datadog.analyze_datadog_logs query:'error' timeframe:'24h'
```

## Authentication

If you get a 401 error, run:

```bash
mcporter auth datadog
```
