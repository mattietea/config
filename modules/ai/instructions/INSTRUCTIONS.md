# Global Instructions

Universal preferences for all AI coding tools.

<important if="you are looking up documentation, API references, or library usage">

Use **context7** first — it has up-to-date docs with code examples. Fall back to web search only if context7 doesn't cover it.

</important>

<important if="you encounter ambiguity, edge cases, or seemingly conflicting rules in a project's AGENTS.md, CLAUDE.md, or similar instruction files">

**Do not rationalize-and-proceed.** When a rule is unclear at the edges:

1. **Default to the strict literal reading** of the rule. Edge cases resolve in favor of the rule.
2. **If still genuinely ambiguous**, ask ONE focused question and stop. Do not act under a guessed interpretation.

NEVER write narration that combines unilateral action with soft permission-seeking. This pattern — identifying ambiguity, resolving it yourself, then saying "but the user can override if needed" — is forbidden.

Canonical bad example (do NOT do this):

> "On the AGENTS.md rule about prefixing agent-posted comments: the PR close comment will be posted under the user's identity rather than a bot account, which creates some ambiguity. I'll default to adding the [Claude Code] prefix since that's what the rule specifies, but the user can override if needed. For the auto-resolve items, I'll add the prefix, save the Slack reply to the specified path, and leave the branch intact until the user decides."

Why this is forbidden:

- It identifies ambiguity, then resolves it unilaterally
- It wraps the action in "but you can override" language to dodge commitment to either following or asking
- It bundles multiple unrelated decisions ("for the auto-resolve items, I'll do A, B, and C") as a fait accompli
- It reads like internal monologue posing as communication

The correct alternatives:

- **Follow strictly**: "The rule says prefix with [Claude Code]. Doing so." (No narration.)
- **Or ask once**: "The PR close comment will post under your identity, not a bot — should I still apply the [Claude Code] prefix?" Then stop and wait.

Never both, never bundled, never narrated.

</important>

<important if="you need to search the web for information">

Use **Exa** (MCP server) first — higher quality, focused results. Fall back to generic web search only when Exa doesn't cover the topic.

</important>

<important if="I ask you to look at a tab, browser tab, or any of my open tabs">

Use the **playwriter** skill. Playwriter connects to my running Chrome via a browser extension, so my logins, cookies, and extensions are already there — unlike agent-browser which spawns a fresh browser.

</important>

<important if="you are asked to load a website, visit a URL, fill a form, or interact with a web page (and it is NOT one of my already-open browser tabs)">

Use the **agent-browser** skill. Only use Chrome DevTools MCP when I explicitly ask for DevTools, debugging, performance analysis, or network inspection. If I am referring to a tab in my running Chrome, use the **playwriter** skill instead.

</important>

<important if="you are splitting a large PR, creating stacked PRs, managing branch dependencies, or rebasing a chain of branches">

Use the **git-machete** skill (`/git-machete`). Use `git m` (alias for `git machete`) to manage stacked branch trees and create PRs that show their position in the stack.

</important>

<important if="you need to read or send a Slack message, search Slack, browse channel history, or interact with Slack in any way">

Use the **agent-slack** skill (`/agent-slack`). Run `agent-slack` CLI commands — it handles messages, threads, search, reactions, channels, and more. Auth is already bootstrapped.

</important>
