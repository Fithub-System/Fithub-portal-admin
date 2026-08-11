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
| MCP tools used | HTTP JSON-RPC `tools/call` → `get_screen` on `https://stitch.googleapis.com/mcp` (Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-10T09:02:00Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2048` | From MCP `get_screen` |
| Page background | `#121212` | Brand Lock |
| Direction | RTL | EasyLocalization `ar` + Directionality |

Screenshot (MCP AR): `Docs/feat30-assets/stitch-ar-mcp.png`  
App screenshot: `Docs/feat30-assets/app-ar-payout-queue.png`

---

## Regions

Same 7 content regions as EN card, mirrored RTL:

1. Rail end-side in LTR terms → start in RTL with **المدفوعات** active  
2. Title `طابور السحوبات`  
3. KPI strip (same metrics) — below header (Stitch SoT)  
4. Filters: الكل / قيد الانتظار / مدفوع / مرفوض — below KPIs  
5. Table columns mirrored  
6. Actions: تعيين كمدفوع / رفض  
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

---

## Side-by-side evidence

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (MCP) | `Docs/feat30-assets/stitch-ar-mcp.png` |
| App screenshot | `Docs/feat30-assets/app-ar-payout-queue.png` |
| Region checklist | `Docs/feat30-region-checklist.md` |
