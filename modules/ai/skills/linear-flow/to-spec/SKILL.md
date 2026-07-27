---
name: to-spec
description: Turn the current conversation into a spec and save it to ~/notes — no interview, just synthesis of what has already been discussed. Use after grilling, before cutting tickets.
disable-model-invocation: true
---

# To Spec

Synthesize the current conversation into a spec. Do NOT interview the user — the decisions were already made (usually in a grilling session); write them down.

## Process

1. Explore the repo if you haven't already, so module names and domain terms are accurate.
2. Sketch the seams where the work will be tested. Prefer existing seams, as high as possible — the ideal number is one. Confirm the seams with the user; this is the only question this skill asks.
3. Write the spec to `~/notes/<area>/<YYYY-MM-DD>-<slug>-spec.md` and report the path.

<spec-template>

## Problem

## Invariants

What must not break.

## Decisions

Implementation and architectural decisions as made in the conversation.

## Testing

The seams, what good tests look like here, prior art in the codebase.

## Measure

How done is measured — the metric and where it's tracked, when one exists.

## Out of scope

</spec-template>

Bullets, not prose. No file paths or code snippets — exception: a snippet that encodes a decision more precisely than prose can (schema, type shape, state machine).

Next step: cut it into tickets with `/to-tickets <spec path>`.
