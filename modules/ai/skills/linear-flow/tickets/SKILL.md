---
name: tickets
description: Break a plan, spec, or the current conversation into scaffolded Linear tickets — one parent issue plus tracer-slice sub-issues linked by native blocking relations. Use when asked to cut, scaffold, or create tickets for a chunk of work.
disable-model-invocation: true
---

# Tickets

Break the work discussed (or the spec/issue passed as an argument) into Linear tickets. Team, states, labels, and scaffold conventions are in your instructions; use the linear-cli skill for all Linear operations.

## Process

1. **Gather.** Work from conversation context. If an argument references a spec or issue, fetch it and read the full body and comments.
2. **Slice.** Draft tracer-bullet slices: each independently landable and verifiable on its own (CI green, metric moves, test exists), sized to one fresh agent session. For a wide mechanical refactor (rename, retype, package move) use expand–contract instead: an expand ticket, migrate-batch tickets sized by blast radius (per package or directory), and a contract ticket blocked by every batch.
3. **Measure.** If the work claims a measurable outcome (fewer errors, faster X), name the metric and where it's tracked — find or create it via the Datadog skills. If no measurement exists yet, the first slice is the instrumentation that makes it visible, blocking the rest. If a cheap proxy metric exists for hygiene work (dependency age, suppression count), suggest it; if measuring would be theater, skip without ceremony.
4. **Quiz.** Present the breakdown as a numbered list — title, blocked-by, and what it proves when done. Ask whether the granularity and blocking edges are right. For production-touching work, ask once: gated? what monitor catches a regression? rollback path? Iterate until approved. Ask one question at a time.
5. **Publish.**
   - Parent issue in the matching project: problem, invariants (what must not break), and the measure — metric plus a link to where it's tracked, when one exists.
   - One sub-issue per slice, blockers first, wired with native blocked-by relations (`linear issue relation add`).
   - Each sub-issue unassigned in `Todo` with an `effort:S/M/L` label; topical label only if one clearly fits.

## Ticket style

- One-line title; description of at most 4 bullets.
- No file paths or code snippets — they go stale.
- Written so any engineer can pick it up cold, with no reference to this conversation.
