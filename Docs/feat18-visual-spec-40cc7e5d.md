# Visual Spec Card — Class Manager (FEAT-18)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-18 Portal Classes |
| Stitch project | `13435235862240753621` |
| Screen id | `40cc7e5d1f27417f9e6681c0fe14b180` |
| Stitch title | Class Manager |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `40cc7e5d1f27417f9e6681c0fe14b180` · AR `3f356939493b4a79980687040e5e4fa2` · companion RTL/LTR `23bf29b39a034e8fb52f790eb4927b49` (optional) |
| MCP tools used | HTTP JSON-RPC `tools/call` → `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `x-goog-user-project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-06T10:05:00Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2524` | DESKTOP artboard |
| Page background | `#131313` | `background` / Kinetic `stitchBackground` |
| Primary surface | `#1C1B1B` / `#0E0E0E` | form card / detail panel |
| Accent | `#CCFF00` / `#C3F400` | electric lime / primary container |

Screenshot (MCP EN): `Docs/feat18-assets/stitch-en-screenshot.png`  
HTML (MCP EN): `Docs/feat18-assets/stitch-en.html`  
Screenshot (MCP AR): `Docs/feat18-assets/stitch-ar-screenshot.png`  
HTML (MCP AR): `Docs/feat18-assets/stitch-ar.html`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar (6-rail) | Sticky start, Classes active | shell | rail `#0A0A0A` | `_PortalNavigationRail` (FEAT-11 — unchanged) |
| 2 | TopNavBar | Sticky header | shell | blur charcoal | `_PortalShellHeader` |
| 3 | Weekly Schedule header | Main pad ~`p-8` | — | page `#131313` | `ClassManagerScreen` / `_MainColumn` |
| 4 | Title + week range | Start | — | Lexend black uppercase | `classes.manager.title` + date range |
| 5 | Week nav | End | gap-2 | outline chevrons + Today | `_WeekNav` |
| 6 | Weekly grid | 8-col (Time + Mon–Sun), hours 06–12 | cell borders | lowest surface, `rounded-lg` | `ClassWeeklyScheduleGrid` |
| 7 | Session cards | In-grid | pad 4 | low surface + blue/lime start border | `_SessionCard` |
| 8 | Schedule New empty | Wed 09 empty chrome | dashed | + icon + label | `_EmptySlot` (Admin only) |
| 9 | Add New Session form | Below grid | `p-6` | `#1C1B1B` `rounded-xl` | `ClassSessionFormPanel` |
| 10 | Detail / Attendee panel | End `w-96` | `p-8` | `#0E0E0E` | `ClassSessionDetailPanel` |
| 11 | Capacity + attendee fixtures | Detail body | — | lime progress; avatar rows | Stitch fixtures (no booking Backend) |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Page title | Lexend | ~`text-4xl` / 36 | black uppercase | `#FFFFFF` | tight | `WEEKLY SCHEDULE` |
| Week range | Inter | ~13 | regular | `#C4C9AC` | — | `OCTOBER 23 — OCTOBER 29, 2023` |
| Day header | Inter | 10 / 16 | semibold / bold | muted / white | — | `MON` / `23` |
| Session title | Inter/Lexend | ~10 | extrabold | white / lime when selected | — | `POWER YOGA` |
| Form title | Lexend | ~xl | bold uppercase | white | — | `ADD NEW SESSION` |
| Form labels | Inter | 11 | semibold uppercase | `#C4C9AC` | — | `CLASS TYPE` |
| Detail title | Lexend | headline | black | white | — | `POWER HIIT` |
| Attendee name | Inter | body | bold | white | — | `Alex Rivera` |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Today button | ~40 | square outline | transparent | outline-variant | — | week reset |
| Schedule New | cell | 8 | transparent | dashed muted | 18 | Admin only |
| Session card | ~row | 8 | `#1C1B1B` | start 3px blue/lime | — | tap selects |
| Create Class CTA | 48 | 8 | `#FFFFFF` | none | — | Admin; disabled for Receptionist |
| Active Now pill | — | full | `#C3F400` | none | — | in-session window |
| Capacity bar | 8 | 4 | track high / lime fill | — | — | fixture `21 / capacity` |
| Bulk Check-In | 48 | 8 | outline lime | lime | — | chrome only (no booking) |

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty week | Schedule New cell | Admin sees dashed CTA; Receptionist empty cells |
| Loading | — | Lime spinner until first load |
| Error | load failure | Retry + message key |
| Selected session | Detail panel | Attendee fixture chrome |
| Disabled write | Receptionist | Form CTAs disabled; Schedule New hidden |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard / scroll | Platform |
| Live sessions vs Stitch sample titles | Binding |
| Attendee rows fixture until booking FEAT | Backend defers attendees |
| Capacity booked count fixture `21` | No booking engine in FEAT-18 |
| Soft-cancel via more menu | AC-B5; not a separate artboard |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat18-assets/stitch-en-screenshot.png` |
| Stitch AR screenshot | `Docs/feat18-assets/stitch-ar-screenshot.png` |
| App screenshot | Widget-test region evidence (`test/feat18_class_manager_test.dart`) — full device capture deferred to BizDev manual P1/P6 |
| Golden / region checklist | `Docs/feat18-class-manager-region-checklist.md` |
