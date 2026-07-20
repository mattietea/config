---
name: work
description: Pick up a Linear ticket and drive it to a PR. Use when asked to work on, start, or implement a ticket by id (e.g. FEPLAT-123).
disable-model-invocation: true
---

# Work

Drive one Linear ticket to a review-ready PR. One ticket per session — if asked to take several, do the first and recommend fresh sessions for the rest.

## Process

1. **Read.** `linear issue view <id>` — full body, comments, parent, and relations. If a blocking issue is still open, stop and report it instead of starting.
2. **Claim.** `linear issue start <id>` — assigns, branches, and moves to In Progress.
3. **Align.** Restate what done means in one or two lines. If the ticket is ambiguous, ask before writing code.
4. **Build.** Use /tdd wherever a seam allows a failing test first. Typecheck and run affected tests as you go; run the full relevant suite once at the end.
5. **Review.** Run /code-review on the diff and fix what it finds.
6. **PR.** Push and open the PR — the branch name links it to Linear. Follow the PR conventions in your instructions. Move the ticket to In Review. If the parent issue declares a measure, comment on the ticket where the effect should be visible — the graph is the validation, not a follow-up ticket.
