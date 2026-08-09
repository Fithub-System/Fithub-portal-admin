# Visual Spec Card — Admin Payout Queue (AR RTL)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-30 Portal |
| Stitch project | `13435235862240753621` |
| Screen id | `142d4cb868ff4aff8c040453bad737f9` |
| Stitch title | Admin Payout Queue (Arabic RTL) |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `405663d1534848d2a96f1db4e76c35df` · AR `142d4cb868ff4aff8c040453bad737f9` |
| MCP tools used | **BLOCKED this session** — same as EN card (401 / no `GOOGLE_STITCH_API_KEY` / no gcloud account). IA from `@specs/stitch-inventory-milestone-6.md` AR extract. |
| Fetched at (UTC) | 2026-08-09T23:55:00Z (attempt) |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | DESKTOP (ESTIMATED) | Pending MCP |
| Page background | `#121212` | Brand Lock |
| Direction | RTL | EasyLocalization `ar` + Directionality |

Screenshot (MCP): **pending**  
App screenshot: `Docs/feat30-assets/app-ar-payout-queue.png` (when captured)

---

## Regions

Same 7 content regions as EN card, mirrored RTL:

1. Rail end-side in LTR terms → start in RTL with **السحوبات** active  
2. Title `طابور السحوبات`  
3. Filters: الكل / قيد الانتظار / مدفوع / مرفوض  
4. KPI strip (same metrics)  
5. Table columns mirrored  
6. Actions: تعليم كمدفوع / رفض  
7. Footer ops-only copy  

---

## Typography / Components

Mirror EN card; Arabic copy from `assets/translations/ar.json` `payouts.*`. Brand Lock tokens unchanged (`#CCFF00` / `#FF3B30` / `#121212`).

---

## Allowed deltas

| Delta | Reason |
|-------|--------|
| RTL mirroring of EN layout | FEAT-03 |
| Live vs fixture rows | Binding |
| Exact Stitch px pending MCP | OAuth residual |

---

## Side-by-side evidence

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (MCP) | **BLOCKED** |
| App screenshot | `Docs/feat30-assets/app-ar-payout-queue.png` |
| Region checklist | `Docs/feat30-region-checklist.md` |
