# Visual Spec Card (VF1-R amendment) — Admin Overview §4.1 fixtures

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF1-R |
| Stitch project | `13435235862240753621` |
| Screen id | `216e0407184f4c39bd501ed436c1e88b` |
| Stitch title | Admin Overview Dashboard |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `216e0407184f4c39bd501ed436c1e88b` · AR `167e03106e8c45c6b47b8ecb48116624` (Admin Overview Arabic RTL) |
| MCP tools used | HTTP JSON-RPC `tools/call` → `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; gcloud OAuth Bearer + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-04T08:29:27Z |
| Author agent | Portal Admin Agent |
| Parent Spec Card | `Docs/feat16-vf1-visual-spec-216e0407.md` (layout VF1) |

Screenshot (MCP): `Docs/feat16-vf1r-assets/stitch-216e0407-screenshot.png`  
HTML (MCP): `Docs/feat16-vf1r-assets/stitch-216e0407.html`

---

## Fixture sample content (§4.1 — REQUIRED)

Marked `fixture`. Must render when Backend unbound — **not** blank / bare `—` shells. Live occupancy + FEAT-12 scanner remain bound.

| Region | Fixture values | Flutter |
|--------|----------------|---------|
| Daily Yield amount | `$12,482` | `OverviewStitchFixtures.yieldAmount` → `DailyYieldCard` |
| Daily Yield delta | `+14.2% vs yesterday` | `OverviewStitchFixtures.yieldDelta` |
| Expiring row 1 | Marcus Thorne · m.thorne@example.com · ELITE PERFORMANCE · May 24, 2024 · Tomorrow (urgent) | `ExpiringMembershipsCard` |
| Expiring row 2 | Elena Rodriguez · elena.r@example.com · FOUNDRY BASIC · May 25, 2024 · In 2 days | same |
| Access Granted sample | John Smith · ID `#KM-88219` · Active Member · ACCESS GRANTED bar | `AccessGatePanel` (always on artboard; live approved scan replaces name) |
| Footer Total Active | `2,841` | `OverviewFooterStats` |
| Footer Classes Today | `42` | same |
| Footer Guest Passes | `12` | same |
| Footer Incident Reports | `0` | same |

---

## Allowed deltas (VF1-R)

| Delta | Reason |
|-------|--------|
| Live occupancy count vs Stitch `80/100` | Bound FEAT-04 |
| Live approved scan name vs John Smith | FEAT-12 binding replaces fixture |
| Rejected scan hides Access Granted sample | Product state (reject) |
| Avatar photos → initials / person icon | Avoid network asset flakes; same structure |
| RENEW ALL non-navigating | No renew API |

**Forbidden (FAIL):** bare `—` for Yield/footer; empty expiring table; omitting Access Granted sample chrome when idle.

---

## Side-by-side evidence

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf1r-assets/stitch-216e0407-screenshot.png` |
| Region checklist | `Docs/feat16-vf1r-region-checklist.md` |
| Widget evidence | `test/feat16_vf1_overview_fidelity_test.dart` |
