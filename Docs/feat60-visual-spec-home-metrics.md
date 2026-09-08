# Visual Spec Card — FEAT-60 Portal Home live metrics (layout delta)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-60 Portal Home live metrics |
| Stitch project | `13435235862240753621` |
| Screen id | `216e0407184f4c39bd501ed436c1e88b` |
| Stitch title | Admin Overview Dashboard |
| AR twin | `167e03106e8c45c6b47b8ecb48116624` |
| MCP tools used | Unavailable in session catalog (`user-stitch` missing) — cite locked Overview id + owner soft-lock |
| Fetched at (UTC) | 2026-09-08 |
| Author agent | Portal Admin Agent |
| Parent Spec Cards | `Docs/feat16-vf1-visual-spec-216e0407.md`, `Docs/feat16-vf1r-visual-spec-216e0407.md` |

---

## Owner layout delta vs Stitch HTML

Stitch artboard / HTML region order (mid-before-footer):

1. Hero — Live Occupancy \| Daily Yield  
2. Mid — Expiring Memberships \| Access Gate  
3. Footer — Insights stats (4 tiles)

**Owner soft-lock (2026-09-08) — shipped order:**

1. Hero — Live Occupancy \| Daily Yield  
2. **Insights / footer stats** (immediately under Occupancy + Revenue)  
3. Mid — Expiring Memberships \| Access Gate  

Flutter keys: `overview-hero-row` → `overview-insights-row` → `overview-mid-row`.

---

## Live vs fixture bind

| Region | Binding | Notes |
|--------|---------|-------|
| Live Occupancy | Live (FEAT-04) | Unchanged |
| Daily Yield amount | **Live** — paid `membership_charges` sum for **UTC today** | Format `{CURRENCY} {amount}` (e.g. `EGP 0`); empty/0 honest |
| Daily Yield delta % | **Omitted** | Shows `—` when yesterday unavailable — no invented +14.2% |
| Expiring Memberships | **Live** — active roster `ends_at` within **48h** | Empty chrome when none — **no** Marcus/Elena fixtures |
| Insights · Total Active | **Live** — roster count | |
| Insights · Check-ins today | **Live** — `attendance_logs` count UTC today | Label replaces Classes Today |
| Insights · Guest Passes | **Fixture** until FEAT-62 | Stitch `12` |
| Insights · Incident Reports | Fixture (not in owner live list) | Stitch `0` |
| Access Gate | Unchanged (FEAT-12) | |

---

## Forbidden

- Masking empty live KPIs with Stitch `$12,482` / Marcus / Elena / `2,841` / `42`
- Inventing non-zero revenue, check-ins, or members counts
- Fake yield delta % when yesterday data unavailable
- New rail destinations

---

## Evidence

| Artifact | Path |
|----------|------|
| Widget / layout tests | `test/feat60_home_metrics_test.dart` |
| Verification Audit | `Docs/feat60-home-metrics-verification-audit.md` |
| Manual | `Fithub-documentation/manual-tests/PHASE-FEAT-60-manual-test.md` |
