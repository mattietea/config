---
name: frontend-instrumentation
description: "Instrumenting a React/TypeScript app with Datadog RUM: error taxonomy and reporting, custom actions/views/timings, sampling strategy, source maps, feature flags, Core Web Vitals. Use when adding or reviewing RUM instrumentation, wiring error boundaries, naming views/actions, configuring the RUM SDK init, deciding sample rates, or when errors/metrics in Datadog look incomplete or noisy at the source."
---

# Frontend Instrumentation (Datadog RUM)

Prescriptive rules for instrumenting a React/TypeScript app. Each rule: what to do, why the naive version fails, the API shape.

## Errors

**Report every caught-but-unexpected exception with `addError`.** The SDK only auto-captures *unhandled* exceptions/rejections, `console.error`, and ReportingObserver reports. Anything a data-fetching library catches is invisible unless reported. Pass real `Error` objects (Error Tracking requires a stack trace), attach context: `datadogRum.addError(err, { feature: 'checkout' })`.

**Triage on `@error.handling` first.** Datadog sets `handled` (via addError) vs `unhandled` (window-level) automatically. Alert on unhandled; dashboard handled. Mixing them makes thresholds meaningless.

**Wrap route-level trees in reporting error boundaries.** Use `@datadog/browser-rum-react`'s `ErrorBoundary` (or `addReactError(error, errorInfo)` in your own `componentDidCatch`) with `plugins: [reactPlugin()]` at init — render errors otherwise produce a white screen with no contextualized signal.

**Classify expected noise at the source in `beforeSend` — drop or tag it.** Extension errors, ad-blocker-broken third-party scripts, offline fetch failures, `AbortError` cancellations, auth-expiry 401s, ResizeObserver-loop warnings: filter or tag `expected: true`. Principle: only report errors someone will fix. But do NOT blanket-filter network errors — CORS/SSL/JSON-parse failures are actionable. `beforeSend` can discard any event type except views.

**Fingerprint errors with variable messages.** Default grouping = service + type + message tokens + top frame; dynamic messages over-split, wrapper functions over-merge. Set `error.dd_fingerprint` on the Error, or `event.error.fingerprint` in `beforeSend` (SDK ≥4.42).

**Encode severity by convention.** RUM errors have no native severity. Standardize a context key (`severity: 'critical' | 'degraded' | 'info'`) in a shared helper and monitor on `@context.severity`.

## Views, actions, timings

**Name SPA views by route pattern, never URL.** `/user/123` and `/user/456` must aggregate as `/user/:id` or per-template budgets/monitors break. React Router: `reactPlugin({ router: true })` + the plugin's `createBrowserRouter`. Otherwise `trackViewsManually: true` + `startView({ name })` at the router level, or rewrite `event.view.name` in `beforeSend`.

**Instrument business-critical flows as custom actions with stable names.** Auto-collected click names come from innerText — they drift with copy and localization. `datadogRum.addAction('checkout.payment_submitted', { cartValue })`; convention `domain.object_verb`, lowercase. For auto-collected clicks add `data-dd-action-name` to elements; `enablePrivacyForActionName: true` if innerText may hold PII.

**Add custom timings/duration vitals for the moments defaults can't see** (hero rendered, grid interactive): `addTiming('hero_image')` (relative to *view* start, not page load), `startDurationVital`/`stopDurationVital`, `setViewLoadingTime()` when automatic activity detection misfires. Exclude heartbeat/analytics URLs from loading_time via `excludedActivityUrls`.

**Report feature-flag evaluations** so rollouts are debuggable by variant: `addFeatureFlagEvaluation(key, value)` in the flag client's evaluation hook (native callbacks exist for LaunchDarkly, Statsig, etc.). "Did the regression only hit `new_checkout=true`?" is unanswerable otherwise.

**Attach identity/tenancy/release context up front.** `setUser({ id, plan, ... })`, `setGlobalContextProperty('tenant', ...)` at session start; release goes in `version` at init, not ad-hoc context. High-cardinality attributes on every event beat one custom metric per question — you can derive metrics from events, never the reverse. Keep PII out.

**Centralize all of the above in one shared module** (`observability.ts` exporting `initRum`, `trackAction`, `reportError`, flag hooks) — conventions enforced by code, not review. The raw `datadogRum` object is never imported elsewhere. This module owns the `beforeSend` noise policy and severity convention.

## Sampling and coverage

**Keep `sessionSampleRate: 100`; if cost forces sampling, sample server-side with retention filters.** Client-side sampling decides at session start — before it knows the session will contain an error — so it silently drops rare errors and minority-segment regressions, and ALL RUM metrics (including CWV) are computed only from ingested sessions. Retention filters can keep 100% of error sessions + N% of the rest; the client can't.

**`sessionReplaySampleRate` defaults to 0 and is a percentage OF sampled sessions.** Set both explicitly; document the compounding (60% × 50% = 30% with replay). Consider forcing `startSessionReplayRecording()` for internal/beta cohorts.

**Proxy RUM intake first-party** (`proxy: 'https://app.example.com/dd-intake'`) to recover ad-blocker signal loss — the users you lose are non-random, biasing every metric. The proxy must validate `ddforward` (SSRF), forward the raw body, add `X-Forwarded-For`.

**RUM↔APM correlation is opt-in.** No `allowedTracingUrls` = no correlation. Injected trace headers are not CORS-safelisted — cross-origin APIs must allow them or requests fail in production. Default `traceContextInjection: 'sampled'` lets the backend decide the rest.

## Source maps and releases

**Upload source maps via `datadog-ci sourcemaps upload` in the deploy pipeline, never manually** — re-uploading the same version does NOT override, so stale maps silently win.

**`service` + `version` must match exactly in three places**: SDK init, `--release-version`/`--service` on upload, deploy metadata. Any mismatch = minified stacks with no warning. Use git SHA or `semver+sha`.

## Core Web Vitals

**Source of truth: p75 field data per route template per device type** — never site-wide averages (a checkout LCP regression drowns in marketing traffic) and never lab data alone. Budgets: p75 LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1.

**Capture attribution, not just the number.** "INP 480ms" isn't actionable; "INP on `#submit-button`, 400ms processing, LoAF in vendor.js" is. Datadog collects LCP resource URL / INP target / Long Animation Frames natively; supplement with `web-vitals/attribution` via `addAction` only for missing fields.

**Don't trust vanilla CWV for SPA soft navigations** — INP misses most post-load interactions and route changes have no LCP. Use Datadog's `loading_time` (defined for route changes) plus custom duration vitals around "this route is ready".

## Sources

Datadog docs: [collecting browser errors](https://docs.datadoghq.com/real_user_monitoring/application_monitoring/browser/collecting_browser_errors/) · [advanced configuration](https://docs.datadoghq.com/real_user_monitoring/application_monitoring/browser/advanced_configuration/) · [custom grouping](https://docs.datadoghq.com/real_user_monitoring/error_tracking/custom_grouping/) · [React integration](https://docs.datadoghq.com/integrations/rum-react/) · [tracking user actions](https://docs.datadoghq.com/real_user_monitoring/application_monitoring/browser/tracking_user_actions/) · [page performance](https://docs.datadoghq.com/real_user_monitoring/application_monitoring/browser/monitoring_page_performance/) · [RUM sampling best practices](https://docs.datadoghq.com/real_user_monitoring/guide/best-practices-for-rum-sampling/) · [proxying RUM data](https://docs.datadoghq.com/real_user_monitoring/guide/proxy-rum-data/) · [RUM↔APM](https://docs.datadoghq.com/tracing/other_telemetry/rum/) · [source maps](https://docs.datadoghq.com/real_user_monitoring/guide/upload-javascript-source-maps/) · [feature flags](https://docs.datadoghq.com/real_user_monitoring/feature_flag_tracking/setup/) · [SPA INP](https://www.datadoghq.com/blog/single-page-apps-inp/). Field methodology: [web.dev vitals](https://web.dev/articles/vitals) · [web-vitals library](https://github.com/GoogleChrome/web-vitals). Noise hygiene (transferable): [Sentry](https://blog.sentry.io/making-your-javascript-projects-less-noisy/). Events-over-metrics: Observability Engineering (O'Reilly) · [Honeycomb on high-cardinality frontend events](https://www.honeycomb.io/blog/high-cardinality-instrumentation-wide-events-frontend-apps).
