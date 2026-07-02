---
name: frontend-monitors
description: "Designing meaningful Datadog monitors and SLOs for frontend/RUM data: SLI design, error budgets, burn-rate alerting (multiwindow multi-burn-rate), low-traffic routes, distinguishing one-user error storms from app-wide regressions, page-vs-ticket policy. Use when creating or reviewing any RUM/frontend monitor, defining SLOs, tuning noisy or missing alerts, or interpreting an error spike. Grounded in Google SRE Book/Workbook methodology translated to RUM."
---

# Frontend Monitors & SLOs (Datadog RUM)

Methodology distilled from the Google SRE Book/Workbook, translated to RUM. Use alongside the `/dd-monitors` pup skill: pup is the hands, this is the judgment.

## First principles

- **Page on symptoms users feel** (error-free-view ratio dropped, p75 LCP breached), never on causes (bundle grew, CDN hit-rate fell, API slow). Causes go on the debugging dashboard you open *after* the page.
- **Alert on error-budget burn rate, not instantaneous error rate.** Every SLI is a ratio: good events / valid events. The SLO's complement is the error budget; alerts should fire on *significant budget consumption*, scored on precision, recall, detection time, AND reset time.
- **Percentiles, never means.** Use p75 for user-typical (CWV convention), p95/p99 for tail. Track latency of errored views separately — fast errors deflate latency dashboards exactly when things are worst; slow errors (10s spinner then failure) are the worst case.
- **"Errors" include policy and implicit failures**: a view breaching the latency SLO is a bad view; a 200-response GraphQL payload full of errors, an error-boundary fallback, or an empty-data render is a bad view. Instrument these — status codes miss whole failure classes.

## The one-user error storm (breadth, not volume)

A spike in raw error *events* is compatible with one user in a retry loop, a broken extension, or a hostile network. Regressions are wide; storms are deep. Per-user ratios on low volume are also meaningless (a one-request user sits at 0% or 100%).

- Make the paging SLI **user/session-denominated**: distinct users (or sessions) with ≥1 error on the route ÷ distinct users overall, or error-free session rate. In Datadog: `count_distinct(@usr.id)` over error events vs overall.
- **Error Tracking monitors implement this natively**: measures `Error Occurrences` vs `Impacted Users` vs `Impacted Sessions` (Browser/Mobile issues), grouped by issue fingerprint — e.g. `error-tracking("...").source("browser").impact().rollup("count").by("@issue.id")`. Use the two condition types deliberately: **New Issue** (qualitatively new failure or regression) and **High Impact** (breadth) — they answer different questions.
- Keep raw event counts for debugging dashboards only.
- Before declaring an incident from any spike, check: distinct users affected, distinct sessions, geographic/browser spread, and whether one fingerprint dominates.

## Never do these (each fails a specific way)

- **Static threshold on short-window error rate** ("error rate > 0.1% for 10 min"): terrible precision — can fire 144×/day while the SLO is comfortably met (each firing ≈ 0.02% of a 30-day budget).
- **Just widening the window** (36h): pathological reset — still red 36 hours after the fix ships; on-call learns to ignore red.
- **`for:`-duration conditions** ("above X for 1 hour"): duration doesn't scale with severity (100% outage waits the same hour as 0.2%), and any momentary recovery resets the timer — 5-min 100% error spikes every 10 min never alert while burning 35% of the monthly budget. This is the flapping-canary/bad-flag failure mode most common in frontends.

## Do this: multiwindow multi-burn-rate (the recommended design)

Burn rate = budget-consumption speed; burn 1 = exactly exhausting the budget over the SLO window. For each condition, require BOTH a long window and a short window (= long/12) over the threshold, so alerts stop ~minutes after the problem stops:

| Severity | Long window | Short window | Burn rate | Budget consumed |
|---|---|---|---|---|
| Page | 1 h | 5 min | 14.4 | 2% |
| Page | 6 h | 30 min | 6 | 5% |
| Ticket | 3 d | 6 h | 1 | 10% |

- Datadog SLO burn-rate monitors support long+short windows natively — use them rather than hand-rolled metric monitors.
- Page vs ticket rule: if the issue would exhaust the budget within hours-to-a-couple-days, page; otherwise ticket for the next working day. Pages and tickets are the only valid channels — no email/Slack-spam tier.
- The 3-day ticket is what catches frontend slow leaks: the memory-leaking release degrading LCP 1%/day, the Safari-only error that never spikes.
- Detection math when tuning: time-to-fire = (burn threshold ÷ actual burn) × window; budget consumed at fire = burn × window ÷ SLO period.

## SLO setting

- SLI = good views / valid views, e.g. good = no unhandled error AND critical fetch succeeded AND LCP < T. Exclude synthetics, bots, `env:staging`, internal users from `valid` **in the SLI**, not per-monitor.
- Set the first target from 4 weeks of measured RUM history, rounded down (2 sig figs availability; latency thresholds to 50–100ms) — then iterate. Never promise the aspirational number; track it as a separate, non-enforced aspirational SLO.
- Use a rolling window of integral weeks (28/30 days) — frontend traffic is intensely weekday-cyclical.
- Layer thresholds when the tail matters: "75% of views LCP < 2.5s AND 95% < 5s". Segment mobile/desktop and initial-load/route-change — don't blend.
- Few SLOs, simple SLIs. No composite "health scores" — you can't tell what moved. If quoting an SLO never wins a priority conversation, delete it.
- An SLO without a written, stakeholder-approved error-budget policy (who freezes what when the budget exhausts) is just a KPI.

## Route classes, not per-route tuning

Never hand-tune windows/burn rates per route. Also note the hard limit: multi-alert grouping caps top values per facet (1 facet: top 1000; 2 facets: 30 each; 3: 10; 4: 5) — per-route multi-alerts on a large app **silently skip low-traffic views** beyond the cutoff. Tag views with a class and apply one standard template per class:

| Class | Example | Availability | Latency |
|---|---|---|---|
| CRITICAL | login, checkout | 99.99% | tight |
| HIGH_FAST | core route changes | 99.9% | tight |
| HIGH_SLOW | reports, exports | 99.9% | relaxed |
| LOW | settings, polling | 99% | none |
| NO_SLO | labs, dark launches | none | none |

## Low-traffic routes

At 10 views/hour, one bad view = 1000× burn = an instant page; only ~7 failures are "allowed" per month at 99.9%. Don't mute the monitor — restructure:

- **Minimum-traffic floor** in query arithmetic: `((a/b)*100) * is_greater(b, N)` (errors=a, total=b) zeroes the signal below N events — the officially documented Datadog pattern.
- **Group routes sharing a failure domain** (same bundle, same API) into one SLO; let the 3-day ticket window catch a single dead route.
- **Synthetic traffic** (Datadog Synthetics browser journeys) for signal floor — also your only alert when the site is so down RUM sends nothing. Remember synthetics miss cohort-specific breakage (Safari-only, slow-3G).
- **Client retries with backoff** on chunk/API loads — converts ephemeral failures into good views and de-noises the SLI.
- **Lower the SLO or drop the fast-burn page** for genuinely low-stakes routes.
- Sanity-check extremes: against a lenient SLO (90%), the 2%-in-1h page can be mathematically unfireable; near-perfect targets exhaust budget faster than monitors evaluate — defend those with 1% canary releases (RUM `version` tag comparison) and auto-rollback, not alerting.

## Proving improvements

- **Denominate impact in error budget, not anecdotes**: "this incident consumed 30% of the quarterly budget"; rank incidents and candidate platform projects by budget consumed/saved. Continuous low-grade errors (0.4% of views, always) routinely dwarf dramatic outages in budget terms — surface that.
- **Before/after by release**: tag every deploy via `version` at SDK init; compare error rate and p75 vitals across versions (deployment tracking). Never compare across a sampling-rate change — sampled CWV are proportionally biased.
- **Report SLO compliance weekly (task prioritization) and quarterly (planning)** on rolling 28-day windows; track aspirational SLOs separately from enforced ones.

## Alert review checklist (apply to every existing monitor)

1. Does it detect an urgent, actionable, user-visible condition that nothing else catches?
2. Is it user/session-denominated (or budget-based) rather than a raw count?
3. Does it exclude synthetics/bots/staging/internal in the SLI?
4. Will it stop firing promptly once fixed (short-window reset)?
5. Could low traffic make one user trip it (needs floor/grouping)?
6. Is the response rote? Automate it instead of paging.
7. Has it fired usefully in the last quarter? If not, fix or delete.
8. Would you ever ignore it as benign? Then change it now — tolerated noise masks real pages.

## Sources

[SRE Workbook: Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/) (burn-rate math, multiwindow tables, low-traffic strategies) · [SRE Workbook: Implementing SLOs](https://sre.google/workbook/implementing-slos/) (SLI ratios, route classes, per-customer aggregation, budget policy) · [SRE Book: Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) (golden signals, symptoms vs causes, page tests) · [SRE Book: Service Level Objectives](https://sre.google/sre-book/service-level-objectives/) · [Datadog: minimum request threshold for error-rate alerts](https://docs.datadoghq.com/monitors/guide/add-a-minimum-request-threshold-for-error-rate-alerts/) · [Datadog: SLO burn-rate monitors](https://docs.datadoghq.com/service_management/service_level_objectives/burn_rate/).
