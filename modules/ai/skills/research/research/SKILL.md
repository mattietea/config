---
name: research
description: Investigate a question against high-trust primary sources and capture cited findings in ~/notes. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

# Research

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Check `~/notes` for prior findings on the topic; build on them instead of re-researching.
2. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
3. Write the findings to `~/notes/<area>/<YYYY-MM-DD>-<slug>.md` (`<area>` = repo or topic), citing each claim's source. Link the related Linear issue at the top when there is one. Never write findings into a work repo.
4. Report back with the file path and a few-bullet summary in the conversation.
