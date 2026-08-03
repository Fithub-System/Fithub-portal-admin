# Visual Spec Card — Admin Overview Dashboard

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF1 |
| Stitch project | `13435235862240753621` |
| Screen id | `216e0407184f4c39bd501ed436c1e88b` |
| Stitch title | Admin Overview Dashboard |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `216e0407184f4c39bd501ed436c1e88b` · AR `167e03106e8c45c6b47b8ecb48116624` (also catalog: `0e249540074d48ada5e136748b596886`, RTL/LTR `41baa2dac79a4fc58df204481773daf6`) |
| MCP tools used | HTTP JSON-RPC `tools/list`, `tools/call` → `list_screens`, `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; API-key-only `tools/call` → 401 OAuth required; succeeded with gcloud OAuth Bearer + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-03T19:33:10Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2558` | DESKTOP artboard |
| Page background | `#131313` | Tailwind `background` / `surface` |
| Primary surface | `#1C1B1B` | `surface-container-low` cards |

Screenshot (MCP): `Docs/feat16-vf1-assets/stitch-216e0407-screenshot.png`  
HTML (MCP): `Docs/feat16-vf1-assets/stitch-216e0407.html`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar (6-rail) | Sticky start, `w-64` (256px), full height | Brand `p-8`; nav `px-4` | `bg-neutral-950`, `border-r border-neutral-800`; active Home lime text + `border-r-4 #CCFF00` | `_PortalNavigationRail` (+ brand header / Start Workout chrome) |
| 2 | TopNavBar | Sticky, `h-16`, full main width | `px-8` | `bg-neutral-950/80` blur, `border-b border-neutral-800` | `_PortalShellHeader` |
| 3 | Main content pad | Below header | `p-10`, `space-y-10` (40px) | page `#131313` | `AdminOverviewDashboard` |
| 4 | Live Occupancy | Hero grid `col-span-7` | `p-8` | `#1C1B1B`, `rounded-xl` (12), `border-l-4 #4A8EFF` | `LiveOccupancyGauge` |
| 5 | Daily Yield | Hero grid `col-span-5` | `p-8` | `#C3F400` fill, `rounded-xl`, dark on-container text | `DailyYieldCard` |
| 6 | Expiring Memberships | Mid `col-span-8` | header `p-8`, table `p-4` | `#1C1B1B`, `rounded-xl` | `ExpiringMembershipsCard` |
| 7 | Access Gate 1 + Access Granted | Mid `col-span-4`, stacked `space-y-8` | Gate `p-8`; Granted `p-6` | Gate `#1C1B1B` + `border-neutral-800`; Granted `#2A2A2A` + lime ring | `AccessGatePanel` (opens FEAT-12 scanner) |
| 8 | Footer stats cluster | 4-col grid, `gap-4` | card `p-6` | `#0E0E0E`, `rounded-lg`, `border-neutral-900` | `OverviewFooterStats` |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Brand mark | Lexend | `text-2xl` (~24) | black (900) | `#CCFF00` | tight | `KINETIC MONOLITH` |
| Brand subtitle | Inter | 10px | regular | `#737373` (neutral-500) | — | `Elite Performance Admin` |
| Rail labels | Lexend | label-sm | uppercase | active `#CCFF00` / idle `#A3A3A3` | — | Home · Members · … |
| Header eyebrow | Lexend | 12px | uppercase tracking-widest | `#737373` | — | `Admin Console` |
| Occupancy title | Lexend | `text-3xl` (~30) | black italic | `#E5E2E1` | tighter | `Live Occupancy` |
| Occupancy count | Lexend | `text-5xl` (~48) | black | `#4A8EFF` | 1 | `80` + `/100` muted |
| Yield title | Lexend | `text-3xl` | black italic | `#556D00` | none | `Daily Yield` |
| Yield amount | Lexend | `text-6xl` (~60) | black | `#556D00` | tight | `$12,482` |
| Section title | Lexend | `text-xl` / `text-lg` | bold uppercase | on-surface | tight | Expiring / Access Gate |
| Caption / timeline | Inter | 10px | bold uppercase tracking-widest | `#6E6E73` / neutral-500 | — | peak hour labels |
| Footer value | Lexend | `text-2xl` | black | on-surface | — | `2,841` |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Rail Start Workout CTA | `py-4` (~56) | `rounded-md` (6) | `#C3F400` | none | — | Chrome only; non-navigating |
| Search field | `py-1.5` | `rounded-md` | `#171717` | focus ring `#CCFF00` | search 14–16 | Decorative in VF1 (no search backend) |
| Occupancy progress | 16px | full | gradient `#4A8EFF`→`#007BFF` on `#262626` | — | — | Live bound |
| RENEW ALL | compact | — | transparent | `border-primary-container/20` | — | Disabled until memberships API binds |
| Access Gate square | aspect 1 | `rounded-lg` | `#171717` | dashed `#262626` | QR ~48 | Tap → scanner focus |
| ACCESS GRANTED bar | `py-3` | `rounded-lg` | `#C3F400` | — | — | Shown after approved scan |
| Stat tile | — | `rounded-lg` (8) | `#0E0E0E` | `#171717` | — | Placeholder counts allowed |

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty | Access Gate waiting | `Waiting for scan...` + Ready pulse |
| Loading | — | Not in artboard |
| Error | Expiring row | Error-tinted expiration (`text-error` `#FFB4AB`) when urgent |
| Disabled | — | Not explicit; RENEW ALL visual only |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard | Platform |
| Scroll overflow | Content > artboard / browser height |
| Live occupancy / scan vs Stitch placeholders (`80/100`, John Smith) | Binding |
| Daily Yield / Expiring rows / footer metrics as `—` or empty table | No Backend contract in FEAT-16; layout chrome matches Stitch |
| Header search non-functional | No search API in scope |
| Mobile bottom NavigationBar | Install adaptive shell (`<600`); DESKTOP artboard remains rail target |
| Flutter focus rings / scrollbars | Platform chrome |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat16-vf1-assets/stitch-216e0407-screenshot.png` |
| App screenshot | `Docs/feat16-vf1-assets/app-overview-desktop.png` (optional human) · widget evidence in `test/feat16_vf1_overview_fidelity_test.dart` |
| Golden / region checklist | `Docs/feat16-vf1-region-checklist.md` |
