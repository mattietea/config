# Work Instructions

Work-host-only preferences. Merged on top of the base instructions.

<important if="I ask you to search, read, or send Gmail; check my calendar or upcoming meetings; or look at files in my Google Drive">

Use the **`gws`** CLI (Google Workspace CLI) — it is installed on this host. It wraps the Google Workspace APIs with my work account credentials.

Common patterns:

- **Gmail**: `gws gmail users.messages list --params '{"q": "from:someone@example.com", "maxResults": 10}'`, then `gws gmail users.messages get --params '{"id": "<id>", "format": "full"}'` to read a thread.
- **Calendar**: `gws calendar +agenda` for upcoming events. `gws calendar events.list --params '{"timeMin": "...", "timeMax": "..."}'` for a custom range.
- **Drive**: `gws drive files list --params '{"q": "name contains '"'"'foo'"'"'", "pageSize": 20}'` to search; `gws drive files get --params '{"fileId": "<id>"}'` for metadata; `gws drive files export` to download as text.
- **Helpers**: `+send`, `+reply`, `+reply-all`, `+forward`, `+triage`, `+watch` (Gmail); `+insert`, `+agenda` (Calendar); `+upload` (Drive).

If `gws auth login` has not been run yet, tell me — auth is interactive and I have to do it.

Prefer `gws` over scraping the Gmail / Calendar / Drive web UI via playwriter or agent-browser. Only fall back to a browser if a workflow is genuinely UI-only (e.g. shared-drive permission dialogs).

</important>

<important if="you are working with Datadog — monitors, dashboards, logs, APM, incidents, or any observability task">

Use the **pup** skill (`/dd-pup`) for Datadog CLI operations. Related skills: `/dd-logs`, `/dd-apm`, `/dd-monitors`, `/dd-debugger`.

</important>

<important if="you are managing Linear issues, creating tickets, updating status, or working with project tracking">

Use the **linear-cli** skill (`/linear-cli`) to manage Linear issues from the command line.

My team is **FEPLAT** (Frontend Platform). Conventions:

- **States**: `Triage` is the team inbox — never scaffold work there. `Todo` + unassigned = grabbable by anyone. `Needs Info` = waiting on reporter. `Canceled` = wontfix; record the why in a closing comment on the issue.
- **Projects are the roadmap** — list them with `linear project list` rather than assuming. Put tickets in the matching project; ad-hoc platform work goes projectless.
- **Scaffolding a chunk of work**: one parent issue holding the terse spec (problem, invariants, how done is measured), sub-issues as slices with native blocked-by relations (`linear issue relation add`), each unassigned in `Todo` with an `effort:S/M/L` label. Use `/tickets`.
- **Starting a ticket**: `linear issue start <id>` (assigns + branches + moves to In Progress); move to `In Review` when the PR opens. Use `/work`.
- **Measures live in Datadog** (dashboards, monitors, CI-emitted custom metrics) — use the pup skills to find or create them. Prefer a cheap measure over none; skip when it would be theater.

</important>

<important if="you are managing git worktrees, configuring worktrunk, setting up hooks, or using wt commands">

Use the **worktrunk** skill (`/worktrunk`) for worktree management, hooks, and commit message generation.

</important>
