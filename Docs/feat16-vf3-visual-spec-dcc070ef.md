# Visual Spec Card — Staff Management (Staff Profile Creator)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF3 |
| Stitch project | `13435235862240753621` |
| Screen id | `dcc070ef2b1e45058b3e042ad70140e3` |
| Stitch title | Staff Management |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `dcc070ef2b1e45058b3e042ad70140e3` · AR `6388be3944bb49aa854b41cfaab32135` (catalog also: Staff Management RTL/LTR `64dc0add064d40bfa9ee7d4b2612bd2a`) |
| MCP tools used | HTTP JSON-RPC `tools/call` → `list_screens`, `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`; API-key alone historically 401) |
| Fetched at (UTC) | 2026-08-03T20:40:00Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `3312` | DESKTOP artboard |
| Page background | `#131313` | `background` / `surface` |
| Primary surface | `#1C1B1B` | `surface-container-low` (cards / table) |
| Table header | `#2A2A2A` | `surface-container-high` |
| Highest / avatar | `#353534` | `surface-container-highest` |

Screenshot (MCP): `Docs/feat16-vf3-assets/stitch-dcc070ef-screenshot.png`  
HTML (MCP): `Docs/feat16-vf3-assets/stitch-dcc070ef.html`  
AR screenshot: `Docs/feat16-vf3-assets/stitch-6388be39-ar-screenshot.png`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar (6-rail) | Sticky start, `w-64`, Staff active lime + `border-r-4 #CCFF00` | Brand `p-8`; nav `px-4` | `bg-neutral-950`, `border-r border-neutral-800` | `_PortalNavigationRail` (shell; IA-locked) |
| 2 | TopNavBar | Sticky `h-16` | `px-8` | `bg-neutral-950/80` blur | `_PortalShellHeader` — staff search placeholder |
| 3 | Page header | Main `p-12`, `space-y-12`, `max-w-7xl` | lime left border `border-l-4 #C3F400` `pl-8` | page `#131313` | `StaffManagementScreen` header |
| 4 | Title block | Start | — | — | `STAFF PROFILE CREATOR` Lexend black ~5xl + subtitle |
| 5 | Active Shifts chip | End | `px-6 py-3` | `#2A2A2A` rounded-md; value lime | `StaffActiveShiftsChip` — fixture `14` |
| 6 | Identity & Credentials | `lg:col-span-8` | `p-8` | `#1C1B1B` `rounded-xl` + white/5 border; `person_add` watermark | Invite name/email + chrome Emergency + Specialization |
| 7 | Access Protocol | `lg:col-span-4` | `p-8` | same card chrome | Role toggles Admin / Trainer / Front Desk |
| 8 | Initialize Profile CTA | Under protocol | `py-4` full width | white → hover lime | FEAT-05 invite submit when `canInvite` |
| 9 | Shift Log header | Full width | schedule icon + title | Export CSV / Filter Range chrome | `StaffShiftLogHeader` |
| 10 | Shift Log table | Full width | header `px-8 py-5` | `#1C1B1B` rounded-xl + border | `StaffShiftLogTable` + §4.1 fixtures |
| 11 | Recent Audit Actions | Half bento | `p-8` | `#1C1B1B` timeline | `StaffAuditFeed` fixtures |
| 12 | Security Compliance | Half bento | `p-8` | `#C3F400` + security glyph | `StaffSecurityComplianceTile` |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Page title | Lexend | `text-5xl` (~48) | black uppercase | `#FFFFFF` (`primary`) | tighter | `Staff Profile Creator` |
| Subtitle | Inter | `text-lg` (~18) | regular | `#C4C9AC` | — | Onboard new personnel… |
| Active Shifts label | Inter | label-sm uppercase tracking-widest | regular | on-surface-variant | — | `Active Shifts` |
| Active Shifts value | Lexend | `text-2xl` (~24) | bold | `#C3F400` | — | `14` |
| Section title | Lexend | `text-xl` / `text-2xl` | bold uppercase | white | — | Identity & Credentials · Access Protocol · Shift Log… |
| Field label | Inter | label-sm uppercase tracking-widest | regular | on-surface-variant | — | Full Legal Name · Professional Email · … |
| Field value | Inter | `text-lg` | regular | white | — | placeholders Johnathan Wick / j.wick@… |
| Role title | Inter | body | bold | white | — | Admin · Trainer · Front Desk |
| Role subtitle | Inter | `10px` uppercase | regular | on-surface-variant | — | Full System Control · Session Management · Check-in & POS |
| CTA | Lexend | body | bold uppercase tracking-[0.2em] | `#283500` on white / lime hover | — | `Initialize Profile` |
| Column header | Inter | label-sm uppercase tracking-widest | bold | on-surface-variant | — | Staff Member · Role · Clock-In · Clock-Out · Total Hours · Status |
| Row name | Inter | body | bold | white | — | Elena Rodriguez · Marcus Thorne · … |
| Row email | Inter | `text-xs` | regular | on-surface-variant | — | elena.r@kinetic.com · … |
| Hours | Lexend | `text-lg` | bold | white | — | `8.35h` / `6.00h` / `8.00h` / `4.00h` |
| Audit title | Lexend | `text-sm` uppercase tracking-widest | bold | white | — | Recent Audit Actions |
| Security title | Lexend | `text-2xl` black uppercase | black | `#556D00` | tight | Security / Compliance |
| Security body | Inter | `text-sm` | medium | on-primary-container/80 | — | ISO-27001 logged & encrypted… |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Active Shifts chip | ~48 | `rounded-md` (6) | `#2A2A2A` | none | — | fixture `14` |
| Identity card | — | `rounded-xl` (12) | `#1C1B1B` | white/5 L+T | person_add ~9xl watermark opacity 10% | 2×2 field grid |
| Underline fields | — | none | transparent | bottom 2px `#444933` → lime focus | — | Name/email bind invite; Emergency/Specialization chrome |
| Specialization select | — | none | transparent | underline | — | 4 Stitch options (chrome) |
| Role row | ~56 | `rounded-lg` (8) | highest/30 | — | 22 | exclusive select; Stitch shows Trainer ON |
| Role switch ON | 24×48 | full | `#C3F400` | — | knob 16 | Trainer selected in artboard |
| Role switch OFF | 24×48 | full | `#353534` | — | muted knob | Admin / Front Desk off |
| Initialize Profile | ~56 | `rounded-md` | white (`primary`) | — | — | FEAT-05 submit; visible disabled when !canInvite |
| Export / Filter | compact | rounded | `#2A2A2A` | — | — | chrome non-navigating |
| Avatar | 40×40 | rounded (4–6) | lime or `#353534` | — | — | initials when photo unbound |
| Role chip Trainer | — | full | blue/10 | — | — | text `#4A8EFF` |
| Role chip Admin | — | full | `#353534` | — | — | muted |
| Role chip Front Desk | — | full | tertiary/10 | — | — | text `#B6C9D8` |
| Status pulse | 8×8 | full | lime | — | — | animate when on-shift |
| Security tile | — | `rounded-xl` | `#C3F400` | — | security ~200 watermark | System Secure + verified |

---

## Fixture sample content (§4.1 — REQUIRED)

Marked `fixture` when Backend shift/audit unbound. Must render — **not** blank table / bare `—` shells.

| Kind | Stitch sample |
|------|---------------|
| Active Shifts | `14` |
| Identity placeholders | Johnathan Wick · j.wick@kinetic.com · +1 (555) 000-0000 · Hypertrophy Specialist |
| Roles (labels) | Admin · Trainer · Front Desk (API wire: Admin / Coach / Receptionist) |
| Shift rows (4) | Elena Rodriguez Trainer 05:54–02:15 8.35h ON · Marcus Thorne Admin 08:00–`--:--` 6.00h ON · Sarah Jenkins Front Desk 04:00–12:00 8.00h OFF · Alex Chen Trainer 10:00–`--:--` 4.00h ON |
| Audit | Updated Permissions: Elena Rodriguez (2 hours ago · Admin Admin) · New Profile Created: Sarah Jenkins (Yesterday · System Automated) |
| Security | Security Compliance · ISO-27001 copy · System Secure |
| Header CTAs | Export CSV · Filter Range (chrome) |

Live invite (FEAT-05) binds name/email/role submit; does **not** collapse shift/audit/security regions. Clock-Out `--:--` is Stitch sample chrome (not a blank cell).

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty | — | **Not** on this artboard — do not ship blank shift log |
| Loading | invite submit | Spinner on Initialize Profile only |
| Error | invite fail | Snackbar; form + fixtures remain |
| Disabled | !canInvite | Initialize Profile visible disabled; form chrome remains; denied copy near CTA |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard / scroll | Platform |
| Avatar photos → initials on Stitch fills | Network/image unbound; same size/weight |
| Trainer / Front Desk labels → API Coach / Receptionist | FEAT-05 wire values preserved |
| Emergency Contact + Specialization not POSTed | No Backend fields; chrome until API binds |
| Export CSV / Filter Range non-navigating | No Backend in scope |
| Live invite success snackbar | FEAT-05 preserve |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat16-vf3-assets/stitch-dcc070ef-screenshot.png` |
| App screenshot | Optional `Docs/feat16-vf3-assets/app-staff-desktop.png` |
| Golden / region checklist | `Docs/feat16-vf3-region-checklist.md` + `test/feat16_vf3_staff_fidelity_test.dart` |
