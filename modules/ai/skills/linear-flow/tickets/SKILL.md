---
name: tickets
description: Break a plan, spec, or the current conversation into scaffolded Linear tickets — tracer slices wired with native blocking relations, spec on the project. Use when asked to cut, scaffold, or create tickets for a chunk of work.
disable-model-invocation: true
---

# Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

The tracker is Linear; team, states, estimates, and scaffold conventions are in your instructions. Use the linear-cli skill for all Linear operations.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Slice along team-ownership boundaries when the work crosses them.** If a slice touches a surface another team owns, or needs their validation, scope that slice to exactly one owning team and make it self-contained — context, affected-item inventory, and acceptance criteria all in the ticket, no references to plans that live elsewhere. Tickets stay on our team by default; handing one off is then a single move to the owning team's Triage, decided deliberately rather than forced by how the work was cut. Apply this only where ownership genuinely crosses — most slices don't need it.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

For production-touching work, ask once: gated? what monitor catches a regression? rollback path?

Iterate until the user approves the breakdown. Ask one question at a time.

### 5. Publish the tickets to Linear

Publish the approved tickets in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers:

- The matching **project** is the program container: its description holds the spec — problem, invariants (what must not break), and how done is measured (a metric plus a link to where it's tracked, when one exists). Never create a program-wide parent issue that duplicates the project.
- One issue per slice using the issue template below, wired with native blocked-by relations (`linear issue relation add`). Sequential chains stay flat — blocked-by is enough; a chain does not need a parent.
- Create a **parent issue only when several same-shaped slices share one spec** (the same change applied per route, package, or surface): the parent holds the shared spec, one sub-issue per instance, and closing it is a coherent milestone — every instance landed.
- Each issue unassigned in `Todo` with a Linear estimate (`--estimate`: 1=S, 2=M, 4=L) — grabbable by construction; topical label only if one clearly fits.

Do NOT close or modify any pre-existing parent issue.

<issue-template>

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

Verifiable completion markers. Where the ticket claims a measurable outcome (fewer errors, faster X), one criterion names the metric and where it's tracked — find or create it via the Datadog skills.

</issue-template>

**Titles are simple, verb-first, Title Case.** The title says what the ticket does in the plainest words that are still concrete — "Setup Alerting Before Datadog v6 Bump", "Add Page Load Metric for `assistant/:id` Route", "Add v5 Traffic Monitor" — never internal jargon or a mechanism's formal name ("content-ready timing", "version-gated validator"): precision lives in the description. If the title needs a qualifying clause to be accurate, cut the clause and let the body qualify. Name the concrete artifact when it disambiguates (route patterns in backticks, the tool, the surface). Prefer the purpose or deadline over the mechanism when that's what a scanner needs ("Before Datadog v6 Bump").

**Coordination chores are not tickets.** Announcements, notifications, and baseline snapshots are acceptance criteria on the tickets that cause the change — a ticket must build or change something.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

Write every ticket so any engineer can pick it up cold, with no reference to this conversation.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom. Work it one ticket at a time with `/work`, clearing context between tickets.
