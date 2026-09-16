# Visual Spec Card — FEAT-95 G4 Add New Member (dialog)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-95 AC-B1–B3, B7 (dialog VF) |
| Stitch project | `13435235862240753621` |
| Screen title | Add New Member (Arabic RTL) |
| Platform | DESKTOP |
| EN screen id | `cd59a129a24449478a5249ccb41635fb` |
| AR screen id | `89fe5d7afb8d4d4384d7e6498bcdd065` |
| AR twin (not locked) | `fed6e7cc19be4d2c9ffd46440c3ef67a` |
| HTML / PNG | `Docs/feat95-assets/stitch-89fe5d7a-ar.html` · `stitch-cd59a129-en.html` |
| MCP tools used | Stitch `get_screen` via Google MCP HTTP (Cursor `user-stitch` namespace unavailable) |
| Author agent | Portal Admin Agent |
| Date (UTC) | 2026-09-16 |

## Intent

Replace the FEAT-13/62 **full-page Scaffold + TabBar** with the locked Stitch
**centered modal overlay** on Members hub. Entry remains Members → Add New
Member (Admin-only).

## Regions

| # | Region | Flutter target | Notes |
|---|--------|----------------|-------|
| 1 | Overlay `fixed inset-0` + `bg-surface/90` + `backdrop-blur` | `AddMemberScreen` `BackdropFilter` + `#E6131313` | Hub stays visible underneath |
| 2 | Card `max-w-2xl` `rounded-2xl` | `formMaxWidth` **720** (FEAT-59) · `dialogRadius` 16 | Stitch `max-w-2xl` is 672; locked width wins |
| 3 | Lime gradient header bar | `_DialogAccentBar` | `primary-container` → `secondary-container` |
| 4 | Title + subtitle | `add_member.title` / `.subtitle` | AR: إضافة عضو جديد / تجهيز ملف تعريف الرياضي |
| 5 | Stepper 01 Find or Invite · 02 Assign Plan | `_DialogStepper` | Artboard wins over AC-B4 “tabs” |
| 6 | LTR search field | `_DeskSearchField` `dir=ltr` | Icon **prefix (LTR start)**; searching **suffix** so LTR digits are not covered (AC-B3; AR HTML overlay bug) |
| 7 | Match cards | `_MatchCard` | `search_athletes_for_desk` debounce 300ms |
| 8 | Divider + name + phone | `_CreateDivider` / `_PhoneField` | Phone prefix `+20` on LTR start |
| 9 | Data verification callout | `_VerificationCallout` | Lime rail on **start** (RTL = right) |
| 10 | Footer | Cancel Request · Next: Step 2 · Enroll & Assign Athlete | Lime CTA: selected match → enroll; else invite if identifier is email/username |

## Tokens

| Token | Value |
|-------|-------|
| surface overlay | `#131313` @ 90% |
| surface-container-low | `#1C1B1B` |
| surface-container-lowest | `#0E0E0E` |
| primary-container | `#C3F400` |
| on-primary-container | `#556D00` |
| secondary-container | `#4A8EFF` |
| radius | 16 (`rounded-2xl`) |

## RTL / AC-B3

Locked AR HTML places `جاري البحث` + search icon at `absolute left-4` on an LTR
input, covering `917-555-0198`. Portal **does not copy that bug**: search chrome
is LTR-forced; icon at prefix (left); searching status at suffix (right).

## Out of scope (this card)

- Paid / Pending radios — **not on G4 dialog artboards** (FSD AC-B4 Design Gap;
  bind on step 2 in a later VF if Owner reopens payment UX).
- Invite QR + expiry countdown (AC-B5 Track B).
- Hub profile CRUD, G1 dual-scan, Athlete `public_code` surfaces.
- Super Plan / Studio / Day-Off (complete; do not reopen).
