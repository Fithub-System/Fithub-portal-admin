# FEAT-60 — Portal Home live metrics — Verification Audit

**Date:** 2026-09-08  
**Branch:** `feature/portal-feat60-home-metrics`  
**Base:** `origin/dev`  
**FSD:** `Fithub-documentation/specs/FEAT-60-PORTAL-HOME-METRICS.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat60-portal-home-metrics.md`  
**GitHub:** [#40](https://github.com/Fithub-System/Fithub-portal-admin/issues/40)  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-60-manual-test.md`

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev
`BizDev Audit: PASS` before merge to `dev`. **Do not merge.**

## Stitch

- Overview EN `216e0407184f4c39bd501ed436c1e88b` (cited on `AdminOverviewDashboard`)
- AR twin `167e03106e8c45c6b47b8ecb48116624`
- Cursor `user-stitch` MCP unavailable this session — citations + Visual Spec Card used
- Visual Spec Card (layout delta): `Docs/feat60-visual-spec-home-metrics.md`

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Revenue live paid today | PASS | `OverviewMetricsSupabaseRemoteDataSource.sumPaidChargesSince` → `DailyYieldCard` |
| AC-A2 Expiring 48h live / empty | PASS | Roster `ends_at` filter; empty → `overview-expiring-empty` (no Marcus/Elena) |
| AC-A3 Insights members + check-ins live; guest fixture | PASS | Footer binds counts; guest leaves null → Stitch `12` |
| AC-A4 Occupancy + Access Gate unchanged | PASS | FEAT-04 gauge + FEAT-12 gate untouched |
| AC-A5 EN/AR + RTL labels | PASS | `check_ins_today`, `delta_unavailable`, `metrics.load_failed` in en/ar |
| AC-B1 Layout Hero → Insights → Mid | PASS | `AdminOverviewDashboard` column order + keys |
| AC-B2 Visual Spec documents delta | PASS | `Docs/feat60-visual-spec-home-metrics.md` |
| AC-B3 Cite Overview Stitch; no new rails | PASS | Screen id constant; rail destinations unchanged |
| AC-C1 Branch from `origin/dev` | PASS | `feature/portal-feat60-home-metrics` |
| AC-C2 User-JWT binds; no service_role | PASS | Roster + attendance SELECT + charges SELECT only |
| AC-C3 Tests empty / guest / layout | PASS | `test/feat60_home_metrics_test.dart` |
| AC-C4 Manual PHASE-FEAT-60 | PASS | Shipped under documentation manual-tests |

## Honesty notes

- Day window: **UTC** for `checked_in_at` / `paid_at` (aligned with Backend same-day unique).
- Revenue format: `{CURRENCY} {amount}` (e.g. `EGP 0`) — documented on Visual Spec Card.
- Yield delta: omitted (`—`) when yesterday unavailable — no fake +14.2%.
- Guest Insights tile remains fixture until FEAT-62.

## Out of scope (confirmed untouched)

- FEAT-61 Renew / Freeze / plan tag
- FEAT-62 Invite + OTP / live Guest passes
- Backend KPI RPC (not required — Portal SELECTs sufficient)

## Tests

- `test/feat60_home_metrics_test.dart`
- Regression: `test/feat16_vf1_overview_fidelity_test.dart`

```text
flutter test \
  test/feat60_home_metrics_test.dart \
  test/feat16_vf1_overview_fidelity_test.dart
```

## Residuals

1. Live Admin smoke vs Backend `dev` paid charges + attendance for UTC today.
2. Dedicated Stitch pixel re-fetch when MCP available.
3. Optional Backend thin KPI RPC if SELECT volume becomes an issue (not needed now).
