# Visual Spec Card — Member Management (Active Roster)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF2 |
| Stitch project | `13435235862240753621` |
| Screen id | `9b35dd57f15443e99f7e798f6867acb6` |
| Stitch title | Member Management |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `9b35dd57f15443e99f7e798f6867acb6` · AR `60b6a0e1f7fb4419b1b0e774ec8bdb32` (catalog also: Member Roster AR `f6cca8491f33470f8715a97754e5aada`, RTL/LTR `90b435dba33c4af9b80caa9eeb67d801`) |
| MCP tools used | HTTP JSON-RPC `tools/call` → `list_screens`, `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`; API-key+OAuth together → auth conflict; API-key alone historically 401) |
| Fetched at (UTC) | 2026-08-03T20:19:32Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2048` | DESKTOP artboard |
| Page background | `#131313` | `background` / `surface` |
| Primary surface | `#1C1B1B` | `surface-container-low` (stats tiles) |
| Table surface | `#0E0E0E` | `surface-container-lowest` |

Screenshot (MCP): `Docs/feat16-vf2-assets/stitch-9b35dd57-screenshot.png`  
HTML (MCP): `Docs/feat16-vf2-assets/stitch-9b35dd57.html`  
AR screenshot: `Docs/feat16-vf2-assets/stitch-60b6a0e1-ar-screenshot.png`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar (6-rail) | Sticky start, `w-64`, Members active lime + `border-r-4 #CCFF00` | Brand `p-8`; nav `px-4` | `bg-neutral-950`, `border-r border-neutral-800` | `_PortalNavigationRail` (shell; out of page widget but IA-locked) |
| 2 | TopNavBar | Sticky `h-16` | `px-8` | `bg-neutral-950/80` blur, `border-b` | `_PortalShellHeader` — member search placeholder |
| 3 | Page header | Main pad `p-10`, `space-y-8` | — | page `#131313` | `MemberManagementScreen` header |
| 4 | Title block | Start | — | — | `ACTIVE ROSTER` italic black 5xl + subtitle |
| 5 | Header CTAs | End | gap-3 | Filter: `#2A2A2A` + outline; Add: `#C3F400` | Filter Type + Add New Member |
| 6 | Stats bento | 4-col grid `gap-4` | tile `p-6` | `#1C1B1B` `rounded-xl`; Elite lime left border; System Health `#4A8EFF` | `MembersStatsBento` |
| 7 | Roster table | Full width | header `px-8 py-5` | `#0E0E0E` `rounded-2xl` + border | `MemberRosterTable` |
| 8 | Table pagination | Footer of table | `px-8 py-6` | low surface strip | `MembersRosterPagination` |
| 9 | Sync footer | Below table | `pt-4` opacity 50% | dots lime + blue | `MembersSyncFooter` |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Page title | Lexend | `text-5xl` (~48) | black italic uppercase | `#FFFFFF` | tighter | `Active Roster` |
| Subtitle | Inter | ~14–16 | regular | `#C4C9AC` (`on-surface-variant`) | — | Managing high-performance athletes… |
| Stat label | Inter | label-sm uppercase tracking-widest | regular | on-surface-variant | — | `Elite Tier` / `Avg XP Level` / … |
| Stat value | Lexend | `text-3xl` (~30) | bold | white (Health: on-secondary-container) | — | `124` / `68.2` / `42` / `Optimal` |
| Column header | Inter | label-sm uppercase tracking-widest | regular | on-surface-variant | — | Member Name · Plan Type · XP Level · Actions |
| Member name | Inter/Lexend | body | bold | white | — | `Dominic Russo` |
| Member ID | Inter | `text-xs` | regular | on-surface-variant | — | `ID: KM-8821` |
| Plan chip | Inter | `10px` | black uppercase tracking-widest | Elite lime / Standard blue / Basic neutral | — | `Elite` / `Standard` / `Basic` |
| XP value | Inter | `text-sm` | bold | white | — | `88` |
| Row actions | Inter | `text-xs` | bold uppercase | muted → white on hover | — | Freeze · Renew · Full Evaluation |
| Pagination | Inter | `text-xs` uppercase tracking-widest | — | muted; strong white for range | — | Showing **1-10** of 1,240 Members |
| Footer meta | Inter | label-sm / 10px uppercase | — | muted | — | Sync Active · API V2.4 · © 2024… |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Filter Type | `py-2.5` (~40) | `rounded-lg` (8) | `#2A2A2A` | outline-variant/30 | filter 14–16 | Opens plans sheet (FEAT-07 preserve; not a freehand tab) |
| Add New Member | `py-2.5` | `rounded-lg` | `#C3F400` | none | — | FEAT-13 enroll when `canEnroll`; else visible disabled chrome (§4.1) |
| Stat tile Elite | — | `rounded-xl` (12) | `#1C1B1B` | left 4px `#C3F400` | — | fixture `124` |
| Stat tile Health | — | `rounded-xl` | `#4A8EFF` | none | — | `Optimal` |
| Avatar initials | 40×40 | `rounded-lg` (8) | `#353534` | — | — | DR / SM / JK / EB |
| Plan chip | — | `rounded-full` | tinted 10% | matching tint border | — | Elite / Standard / Basic |
| XP track | 128×6 | full | `#353534` | — | — | fill gradient lime→blue |
| Full Evaluation | compact | rounded | `#353534` hover `#CCFF00` | — | — | canWrite → Assign sheet (FEAT-07) |
| Pagination page “1” | 40×40 | rounded | `#C3F400` | — | — | chrome |

---

## Fixture sample content (§4.1 — REQUIRED)

Marked `fixture` when Backend roster empty / unbound. Must render — **not** blank table / bare `—`.

| Kind | Stitch sample |
|------|---------------|
| Stats | Elite Tier `124` · Avg XP `68.2` · Active Sessions `42` · System Health `Optimal` |
| Rows (4) | Dominic Russo `KM-8821` Elite XP88 · Sarah Miller `KM-4521` Standard XP42 · Jason Kang `KM-1092` Basic XP15 · Elena Belova `KM-7732` Elite XP94 |
| Pagination copy | Showing **1-10** of **1,240** Members (fixture total) |
| Footer | Sync Active · API V2.4 · © 2024 Kinetic Monolith Systems… |
| Header CTAs | Filter Type · Add New Member |

Live roster **replaces** row names/plans/XP with the same row chrome when cache non-empty; stats Elite/Avg XP derive from live rows; Active Sessions + System Health remain Stitch chrome fixtures until Backend binds those metrics.

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty | — | **Not** on this artboard — do not ship blank roster as empty state |
| Loading | — | Brief spinner acceptable; then fixtures or live |
| Error | load failure | Retry + still prefer fixtures for fidelity when cache empty after fail? Prefer retry UI with Stitch chrome behind — implement: after failure allow Retry; do not leave forever-empty shell |
| Disabled | Add when !canEnroll | Visible, non-navigating |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard / scroll | Platform |
| Live roster rows vs Stitch names | Binding (same structure) |
| Filter Type → plans management sheet | FEAT-07 plan CRUD without freehand Plans tab |
| Full Evaluation → Assign sheet when canWrite | FEAT-07 assign preserve |
| Add New Member gated enable | FEAT-13 Admin enroll |
| Mobile bottom NavigationBar | Install adaptive shell; DESKTOP artboard is rail target |
| Flutter focus rings / scrollbars | Platform chrome |

**Forbidden:** Roster/Plans Material tabs (not on Stitch); blank table; bare `—` cells; collapsing stats/table/footer.

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat16-vf2-assets/stitch-9b35dd57-screenshot.png` |
| App screenshot | Optional `Docs/feat16-vf2-assets/app-members-desktop.png` (widget tests assert regions) |
| Golden / region checklist | `Docs/feat16-vf2-region-checklist.md` |
