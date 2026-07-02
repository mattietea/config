---
name: rum-gap-audit
description: "Systematically finding holes in Datadog RUM data: sampling blind spots, invisible handled errors, SDK signal loss from ad-blockers, broken RUM-APM correlation, missing source maps, uninstrumented journeys, and validating SLI coverage against real user pain. Use when data in Datadog looks incomplete or suspiciously green, when users report problems RUM didn't catch, when auditing instrumentation coverage, or periodically as an observability health check."
---

# RUM Gap Audit (Datadog)

How to find what your telemetry is NOT telling you. Use pup (`/dd-pup`, `/dd-logs`) to run the queries.

## The method (Google SRE coverage audit)

1. **Triangulate implementations.** Every SLI implementation has blind spots: RUM captures real user experience but goes blind where the SDK doesn't load; server logs miss requests that never reached the backend; synthetics miss cohort-specific breakage (one browser, one geography, slow networks). Run at least two implementations of your most critical SLI and investigate divergence.
2. **Correlate independent pain signals against budget burn.** Join support tickets / manually-detected outages / forum complaints against SLO budget consumption. A ticket spike with no SLI dip = coverage gap. An SLI dip with no user pain = precision gap. Quantify with Spearman rank correlation if useful. Investigate both directions.
3. **Fix cheapest-first**: tighten/loosen the SLO, improve the SLI implementation, or move measurement closer to the user.

## Collection-layer gaps (is data arriving at all?)

- **SDK load failures**: ad-blockers and CSP block the SDK and intake for a *non-random* cohort (tech-savvy users, certain regions) — every metric is biased, silently. Mitigate with a first-party intake proxy (`proxy:` init option; validate `ddforward` server-side). Watch RUM intake volume itself as a meta-signal — a drop in views/min with flat backend traffic means collection loss, not user loss. RUM sends nothing when the site is fully down: synthetics are your floor.
- **Sampling**: `sessionSampleRate < 100` proportionally biases ALL metrics including CWV (computed only from ingested sessions) and hides rare errors and minority-segment regressions. `sessionReplaySampleRate` defaults to **0** and is a percentage *of* sampled sessions — verify you actually have replays before the incident, not during. Prefer 100% client-side + server-side retention filters (note: metrics-before-retention-filters applies in RUM without Limits mode; Explorer queries over retained events are still affected).
- **Pollution (the reverse gap)**: synthetics, bots, `env:staging`, and internal users inflating "real user" data. Verify they're excluded in SLIs, not ad hoc per monitor.

## Error-coverage gaps (which failures are invisible?)

- **Caught errors don't exist** unless reported: the SDK auto-captures only unhandled exceptions/rejections, `console.error`, and ReportingObserver. Everything your data-fetching layer catches is invisible without `addError`. Audit: compare `@error.handling:handled` vs `unhandled` volume per route — a route with zero handled errors almost certainly has swallowing `catch` blocks, not perfect code.
- **Render failures**: routes without reporting error boundaries produce white screens with weak or no signal. Audit route-level boundary coverage.
- **Implicit failures**: GraphQL 200-with-errors, empty-data fallbacks, degraded renders — Datadog sees HTTP 200. These need explicit instrumentation to exist at all.
- **beforeSend over-filtering**: review what your noise policy discards; a too-broad network-error filter hides real CORS/SSL/parse failures.

## Attribute & correlation gaps (can you slice and connect?)

- **RUM↔APM has three structural holes**: (1) the initial HTML document and early requests are never correlated — the SDK isn't loaded yet; no configuration closes this (browser-sdk #1833, open). (2) `traceSampleRate` samples out *backend traces only* — RUM sessions exist with no trace; know your rate before declaring "backend has no trace" a mystery. (3) Trace headers aren't CORS-safelisted — cross-origin APIs missing `Access-Control-Allow-Headers` lose correlation silently (or fail preflight). Audit: fraction of resource events with `@_dd.trace_id` per API origin.
- **Missing dimensions**: events without `usr.id`, tenant, plan, `version`, or feature-flag context can't answer "who is affected / which release / which variant". Audit: `-@usr.id:*` share of sessions; views missing `version`.
- **Unparameterized views**: raw-URL view names (`/user/123`) fragment every per-route aggregate. Audit view-name cardinality — hundreds of names for tens of routes means broken naming.
- **Monitor grouping caps**: multi-alert monitors evaluate only top-N facet values (1000/30/10/5 by facet count) — low-traffic views are silently unmonitored. Check what falls below the cutoff.

## Symbolication & release gaps

- **Source maps**: minified stacks in Error Tracking = missing or mismatched maps. `service` + `version` must match exactly between SDK init and `datadog-ci sourcemaps upload`; re-uploading the same version does NOT override — a stale map wins silently. Audit: sample recent error stacks per release for unminified frames.
- **Unversioned deploys**: without `version` at init there is no before/after comparison and no "introduced in" on issues.

## Audit cadence

Quarterly: run the checklist top to bottom; delete monitors that haven't fired usefully (tolerated-noise check); re-run the ticket↔budget correlation for the last quarter; verify replay/sampling rates against what you believe them to be (they drift with SDK upgrades — replay default changed to 0 in v5).

## Sources

[SRE Workbook: Implementing SLOs](https://sre.google/workbook/implementing-slos/) (coverage-audit method, SLI implementation blind spots) · Datadog docs: [RUM sampling best practices](https://docs.datadoghq.com/real_user_monitoring/guide/best-practices-for-rum-sampling/) · [RUM↔APM correlation](https://docs.datadoghq.com/real_user_monitoring/correlate_with_other_telemetry/apm/) · [browser-sdk #1833](https://github.com/DataDog/browser-sdk/issues/1833) · [collecting browser errors](https://docs.datadoghq.com/real_user_monitoring/application_monitoring/browser/collecting_browser_errors/) · [proxying RUM data](https://docs.datadoghq.com/real_user_monitoring/guide/proxy-rum-data/) · [source maps](https://docs.datadoghq.com/real_user_monitoring/guide/upload-javascript-source-maps/) · [RUM monitors](https://docs.datadoghq.com/monitors/types/real_user_monitoring/).
