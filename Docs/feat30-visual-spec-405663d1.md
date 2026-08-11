# Visual Spec Card — Admin Payout Queue (EN)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-30 Portal |
| Stitch project | `13435235862240753621` |
| Screen id | `405663d1534848d2a96f1db4e76c35df` |
| Stitch title | Admin Payout Queue |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `405663d1534848d2a96f1db4e76c35df` · AR `142d4cb868ff4aff8c040453bad737f9` |
| MCP tools used | HTTP JSON-RPC `tools/call` → `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-10T09:02:00Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Value | Notes |
|-------|-------|-------|
| Width × height | `3072` × `2048` (EN DESKTOP) | From MCP `get_screen` |
| Page background | `#121212` | Brand Lock canvas |
| Primary surface | `#1C1B1B` | KPI + table surfaces |

Screenshot (MCP EN): `Docs/feat30-assets/stitch-en-mcp.png`  
HTML (MCP EN): fetched via `htmlCode.downloadUrl` (session)  
App screenshot: `Docs/feat30-assets/app-en-payout-queue.png`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar + **Payouts** active | Sticky start, `w-64` | Brand pad | `#0A0A0A`; active lime | `_PortalNavigationRail` + `PortalShellDestinations.payouts` |
| 2 | Header — Payout Queue + no-PSP subtitle | Top of main | `p-10` rhythm | page canvas | `_Header` in `AdminPayoutQueueScreen` |
| 3 | KPI strip — Pending · Paid today · Rejected today | Below header | tile pad ~20 | `#1C1B1B` + accent left bar | `PayoutKpiStrip` |
| 4 | Filter chips — All / Pending / Paid / Rejected | Below KPIs | chip pad 16×10 | selected lime wash | `PayoutFilterChips` |
| 5 | Table — Coach · Amount · Status · Requested at · Actions | Main | header/row pads | `#1C1B1B` / `#0E0E0E` header | `PayoutQueueTable` |
| 6 | Pending actions — **Mark paid** (lime) · **Reject** (peak coral) | Actions col | CTA pad | lime fill / coral outline | `_ActionButtons` |
| 7 | Footer — ops fulfillment only / no bank transfer | Bottom | — | zinc caption | footer `Text` |
| 8 | Brand Lock tokens | Global | — | `#121212` / `#CCFF00` / `#FF3B30` | `KineticTokens` |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Title | Lexend | ~36 | 900 italic | `#E5E2E1` | 1.1 | Payout Queue |
| Subtitle | Inter/body | 14 | regular | `#6E6E73` | 1.4 | Coach payout requests — fulfill without live PSP |
| Filter label | Lexend | 12 | 700 | lime / zinc | — | All · Pending · Paid · Rejected |
| KPI label | Lexend | 11 | 700 caps | `#6E6E73` | — | Pending / Paid today / Rejected today |
| KPI value | Lexend | 36 | 900 | accent | 1 | counts |
| Table head | Lexend | 11 | 700 caps | `#6E6E73` | — | Coach · Amount · … |
| Row body | Lexend | 14 | 600–700 | `#E5E2E1` | — | coach name / amount |
| Footer | body | 12 | regular | `#6E6E73` | 1.4 | Mark paid records ops fulfillment only — no bank transfer |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Filter chip | ~36 | pill | selected lime 16% / idle `#1C1B1B` | none | — | Default filter = Pending |
| KPI tile | — | 12 | `#1C1B1B` | start accent 4px | — | Peak coral on Rejected today |
| Mark paid CTA | ~36 | 6 | `#CCFF00` | none | — | Admin only |
| Reject CTA | ~36 | 6 | transparent | `#FF3B30` | — | Admin only |
| Status badge | — | 6 | accent 14% | none | — | pending/paid/rejected |

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty filter | table | Empty copy when no rows in filter |
| Loading | initial | Lime `CircularProgressIndicator` |
| Error | load failure | Retry CTA |
| Disabled / RO | Receptionist | Hide Mark paid / Reject; show Read-only |
| Fixture | unbound Supabase | Sample rows for chrome (`AdminPayoutStitchFixtures`) |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard | Platform |
| Scroll overflow | Content > viewport |
| Live data vs fixture sample coaches/amounts | Binding |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat30-assets/stitch-en-mcp.png` |
| App screenshot | `Docs/feat30-assets/app-en-payout-queue.png` |
| Golden / region checklist | `Docs/feat30-region-checklist.md` |
