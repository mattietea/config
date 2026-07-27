---
name: to-tickets
description: Break a plan, spec, or the current conversation into scaffolded Linear tickets — tracer slices wired with native blocking relations, spec on the project. Use when asked to cut, scaffold, or create tickets for a chunk of work.
disable-model-invocation: true
---

# To Tickets

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

**Sequence each group tracer-first.** The first slice of any group is the tracer bullet: the thinnest complete path that proves the whole route works — code to data to dashboard, demoable at the end. It settles the group's shared conventions and builds any shared scaffolding (a hook, a helper, a pattern). Every later slice in the group is a widening: blocked by the tracer, repeating the proven path on the next instance, never re-opening the design. If a group's slices are all unblocked siblings, ask which one is secretly the tracer — one of them almost always is.

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
- **Group related slices under a parent when they add up to one nameable outcome** — same-shaped instances (the same change per route, package, or surface), a multi-step migration ("Migrate Datadog to v7"), or a chain that delivers one capability ("Add Schema Validation to RUM Telemetry"). The parent is the milestone: closing it means something. Never fatten a slice to avoid a parent, and never stretch a parent so broad it duplicates the project. A ticket stays flat only when it's genuinely standalone.
- **Parent bodies are short**: the problem and the end state in a few sentences, plus milestone-level acceptance criteria. Detail lives in the sub-issues — don't narrate the sub-structure (the sub-issue list already shows it), don't restate sub-issue content, and don't leave open design questions as body prose (settling them is the first sub-issue's acceptance criterion; record the answer on the parent once decided).
- Each issue unassigned in `Todo` with a Linear estimate (`--estimate`: 1=S, 2=M, 4=L) — grabbable by construction; topical label only if one clearly fits.

Do NOT close or modify any pre-existing parent issue.

<issue-template>

## What to build

- The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.
- Written as bullet points, not prose paragraphs — one fact or decision per bullet. A body is bullets, code blocks, and tables only; if a sentence wants to be a paragraph, split it or cut it.

## PR Validation

- What to check to prove the PR works, as plain bullets — each a scenario or surface with sub-bullet links to the evidence (devbox, logs/RUM query, metrics explorer, screenshot). For example:
  - old frontend (dd 5.x) / new backend
    - devbox link · RUM logs · AMP logs
  - v5 counter metric (`dp_proxy.v5_validation` by `intake_path`)
    - metrics explorer
- The PR's Validation section mirrors this shape: label bullets with links, no prose narration.
- Match the checks to the change: Datadog queries for telemetry, screenshots plus tests for UI, green re-runs for a flaky fix, a build comparison for a zero-change move. Deploys only reach devboxes; production confirms after the release train.
- Never outcome statements ("validated in production") — outcomes are acceptance criteria; this section is what to check, with the links as the evidence.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

Verifiable markers of the outcome — what is true when this ticket is closed, distinct from how the PR proved it. Where the ticket claims a measurable outcome (fewer errors, faster X), one criterion names the metric and where it's tracked — find or create it via the Datadog skills.

</issue-template>

**Titles are simple, verb-first, Title Case.** The title says what the ticket does in the plainest words that are still concrete — "Setup Alerting Before Datadog v6 Bump", "Add Page Load Metric for `assistant/:id` Route", "Add v5 Traffic Monitor" — never internal jargon or a mechanism's formal name ("content-ready timing", "version-gated validator"): precision lives in the description. If the title needs a qualifying clause to be accurate, cut the clause and let the body qualify. Name the concrete artifact when it disambiguates (route patterns in backticks, the tool, the surface). Prefer the purpose or deadline over the mechanism when that's what a scanner needs ("Before Datadog v6 Bump"). Parents especially name the **outcome** ("Remove PII from RUM Vitals, Actions and Errors"), while their subs may name the mechanism ("Add Schema Validation to Vitals, Actions and Errors").

**Coordination chores are not tickets.** Announcements, notifications, and baseline snapshots are acceptance criteria on the tickets that cause the change — a ticket must build or change something.

Avoid bare file paths and line numbers in prose — they go stale fast. Code snippets and examples are welcome where they encode the decision or intended shape more precisely than prose can: an API call shape, a monitor query, a schema entry, a state machine or type shape (from a prototype or otherwise). Trim to the decision-rich parts — not a working demo, just the important bits. Link prior art where it helps a cold pickup: merged PRs and SHA-pinned GitHub permalinks (the `y`-key kind) are immutable and never rot — "do it like this existing example" plus a link beats re-explaining.

Write every ticket so any engineer can pick it up cold, with no reference to this conversation. The test, applied to each body before publishing: could someone with no context name the exact items they'd change after one read? A migrate ticket that says "update the dashboards" without naming the dashboards, the old and new queries, and the owners fails this test — go collect the inventory before publishing, not after someone picks up the ticket.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom. Work it one ticket at a time with `/work`, clearing context between tickets.
