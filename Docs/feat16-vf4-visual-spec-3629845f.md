# Visual Spec Card — Access Scanner / Check-in Gate (G1)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF4 |
| Stitch project | `13435235862240753621` |
| Screen id | `3629845f7f1e402697f46cf5575e86da` |
| Stitch title | Access Scanner / Check-in Gate |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `3629845f7f1e402697f46cf5575e86da` · AR `bec9356e2cb941798e66fa804ac78854` |
| MCP tools used | HTTP JSON-RPC `tools/call` → `list_screens`, `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-03T21:00:18Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2096` | DESKTOP artboard (EN) |
| AR frame | `2560` × `2112` | RTL twin |
| Page background | `#131313` | `background` / `surface` |
| Primary surface | `#1C1B1B` | `surface-container-low` |
| Viewport / lowest | `#0E0E0E` / `#1A1A1A` | scanner frame fill |
| High surface | `#2A2A2A` | last-member card |
| Lime accent | `#C3F400` | primary-container / CTA |
| Blue accent | `#4A8EFF` / `#ADC7FF` | secondary / Power Score |

Screenshot (MCP): `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png`  
HTML (MCP): `Docs/feat16-vf4-assets/stitch-3629845f.html`  
AR screenshot: `Docs/feat16-vf4-assets/stitch-bec9356e-ar-screenshot.png`  
AR HTML: `Docs/feat16-vf4-assets/stitch-bec9356e-ar.html`  
Meta: `Docs/feat16-vf4-assets/stitch-3629845f-meta.json`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SafeMode offline strip | `h-[24px]` full width | center | `#6E6E73` | `SafeModeBanner` (shell; zinc when offline) |
| 2 | SideNavBar (6-rail) | Sticky start, `w-64` | Brand `px-4`; nav items | `#0E0E0E`, Home active | `_PortalNavigationRail` — **no Scan tab** |
| 3 | Top header | Sticky | `px-8 py-4` | `#131313` | `AccessScannerFocusHost` header + close |
| 4 | Brand / gate eyebrow | Header start | — | — | `KINETIC MONOLITH` + `ADMIN CONSOLE // SECURE ACCESS GATE` |
| 5 | Main grid | `grid-cols-12 gap-8 p-8` | 32 | page `#131313` | `CheckInGateLayout` |
| 6 | Scanner gate panel | `col-span-8` | outer `p-1` + inner `p-8` min-h 500 | `#1C1B1B` + lime glow; lowest inset | `CheckInGateScannerPanel` |
| 7 | Scan viewport | `max-w-2xl aspect-video` | HUD insets | `#1A1A1A` + lime/20 border; scan-line | camera/manual FEAT-01 + Ready-Waiting chrome |
| 8 | Confirm Check-in CTA | under viewport full width | `py-6` | `#C3F400` → granted blue state | `CheckInGateConfirmButton` |
| 9 | System ID / Encryption | under CTA | `mt-4` | 10px uppercase muted | fixture chrome |
| 10 | Stats row ×3 | under gate | `p-6` cards `gap-6` | `#1C1B1B` | Peak Intensity / Avg Dwell / Guest Passes fixtures |
| 11 | Live Occupancy | `col-span-4` | `p-8` | `#1C1B1B` + ring gauge | `CheckInGateOccupancyCard` (live or fixture `42/100`) |
| 12 | Last scanned member | under occupancy | `p-6` | `#2A2A2A` + lime/20 border | Marcus Henderson fixture **or** live success |
| 13 | System Log | under member | `p-4` | `#0E0E0E` mono 9px | `CheckInGateSystemLog` fixtures |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Header brand | Lexend | headline-md | black | `#FFFFFF` (`primary`) | tighter | `KINETIC MONOLITH` |
| Header eyebrow | Inter | 12px | bold | on-surface-variant /60 | — | `ADMIN CONSOLE // SECURE ACCESS GATE` |
| Ready label | Inter | label-sm | uppercase tracking `[0.4em]` | `#C3F400` pulse | — | `Ready - Waiting for Scan` |
| Confirm CTA | Lexend | `text-2xl` (~24) | black | `#556D00` on lime | — | `CONFIRM CHECK-IN` / `ACCESS GRANTED` |
| Meta footers | Inter | 10px | bold uppercase | white/40 | — | `System ID: 098-KM-X` · `Encryption: AES-256` |
| Stat label | Inter | label-sm uppercase | regular | white/50 | — | Peak Intensity · Avg Dwell · Guest Passes |
| Stat value | Lexend | headline-sm | black | `#C3F400` | — | `94%` · `68 MIN` · `04` |
| Occupancy count | Lexend | headline-lg | black | on-surface | — | `42` + `/ 100 LIMIT` |
| Member name | Lexend | title-lg | bold | on-surface | tight | `Marcus Henderson` |
| Plan line | Inter | body-md | regular | on-surface-variant | — | `Premium Monthly` |
| Power Score | Lexend | `text-xl` | black | `#ADC7FF` (`secondary`) | — | `780` |
| System log | mono | 9px | regular | white/40 | — | `GATE_INIT_SUCCESS` … |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Scanner panel | min ~500 | `rounded-lg` (8) | `#1C1B1B` | outline-variant/10 + lime glow | — | outer glow-lime |
| Viewport | aspect-video | `rounded` (2–4) | `#1A1A1A` | lime/20 | QR ~8xl /20 | scan-line animation |
| HUD dots / bar | top-start | — | lime | — | 8px dot + 64×4 bar | decorative |
| Lat/Lng HUD | bottom-end | — | — | — | 10px mono | fixture coords |
| Confirm CTA | ~py-6 | none / rect | `#C3F400` | — | check_circle filled | flips to `#4A8EFF` on grant |
| Occupancy ring | 192×192 | — | track highest / lime arc | stroke 12 | sensors icon | dashoffset sample ~42% |
| Active badge | compact | full | lime | — | — | last member |
| Power bar | 4px | full | secondary 78% | — | — | fixture |
| System log card | — | `rounded` | `#0E0E0E` | outline/10 | — | 4 timestamp lines |

---

## Fixture sample content (§4.1 — REQUIRED)

Marked `fixture` when Backend unbound. Must render — **not** blank/`—` shells.

| Kind | Stitch sample (EN) |
|------|---------------------|
| Waiting state | `Ready - Waiting for Scan` + QR glyph + scan-line |
| Confirm idle | `CONFIRM CHECK-IN` |
| Confirm granted | `ACCESS GRANTED` (interaction / success) |
| System chrome | `System ID: 098-KM-X` · `Encryption: AES-256` |
| Peak Intensity | `94%` |
| Avg Dwell | `68 MIN` |
| Guest Passes | `04` |
| Occupancy (when dash unbound) | `42` / `100 LIMIT` |
| Last member | Marcus Henderson · Premium Monthly · Active · Power Score `780` · Last Check-in Yesterday, 18:45 · Total Visits `142` |
| System Log | `[08:42:01] GATE_INIT_SUCCESS` · `AUTH_CHECK: M_HENDERSON` · `GRANT_ACCESS: CHANNEL_A` · `SYNC_CLOUD_DEFERRED` |
| HUD coords | `LAT: 34.0522 N` · `LNG: 118.2437 W` |

Live FEAT-01 / FEAT-12 scan success **replaces** last-member name/status when present — structure (avatar, plan/badge, power chrome) remains. Occupancy binds DashboardCubit when available; else fixture `42/100`.

AR twin mirrors RTL; copy uses EasyLocalization keys; fixture Latin samples may remain where Stitch AR also shows English tokens (Marcus, READY label).

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Waiting / Ready | Viewport center | QR + `Ready - Waiting for Scan` pulse |
| Confirm idle | CTA lime | `CONFIRM CHECK-IN` |
| Access granted | CTA secondary blue (HTML script) | `ACCESS GRANTED` ~2s / success |
| Last member sample | Aside card | Always populated on artboard (§4.1) |
| Offline strip | Top banner | `SAFEMODE OFFLINE` (shell zinc when offline) |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard | Platform |
| Scroll overflow | Content > viewport |
| Live camera / manual QR path in viewport | FEAT-01 / FEAT-12 — under Ready chrome or replacing glyph when camera active |
| Live occupancy / last member vs fixture | Same cells/chrome; never collapse aside |
| Focus host close control | Product need (not on artboard) — top header |
| AR twin layout variants (bracket camera, Cam/RFID chips) | Mirror intent; EN Spec Card is primary desktop composition |
| Avatar photo → initials | Network asset / unbound |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png` |
| AR twin screenshot | `Docs/feat16-vf4-assets/stitch-bec9356e-ar-screenshot.png` |
| Region checklist | `Docs/feat16-vf4-region-checklist.md` |
| Golden / widget tests | `test/feat16_vf4_access_g1_fidelity_test.dart` |
