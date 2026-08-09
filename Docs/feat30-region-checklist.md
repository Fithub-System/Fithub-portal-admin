# Region checklist — FEAT-30 Admin Payout Queue

**Stitch source:** HTTP MCP `get_screen` **BLOCKED** this session (401 OAuth; `GOOGLE_STITCH_API_KEY` len=0).  
**Fallback IA:** `@specs/FEAT-30-ADMIN-PAYOUT-QUEUE.md` §3 + `@specs/stitch-inventory-milestone-6.md` (BizDev locked 2026-08-10).  
**Brand Lock DS:** `assets/12737976743993098844`

| # | Region | Spec / inventory | Flutter | Status |
|---|--------|------------------|---------|--------|
| 1 | Payouts rail destination | Inventory: Payouts active | `PortalShellDestinations.payouts` + rail/bar | Implemented |
| 2 | Header title + no-PSP subtitle | §3 region 1 | `_Header` | Implemented |
| 3 | Filter chips All/Pending/Paid/Rejected | §3 region 2 | `PayoutFilterChips` | Implemented |
| 4 | KPI Pending / Paid today / Rejected today | §3 region 3 | `PayoutKpiStrip` | Implemented |
| 5 | Table Coach·Amount·Status·Requested·Actions | §3 region 4 | `PayoutQueueTable` | Implemented |
| 6 | Mark paid (lime) / Reject (peak coral) | §3 region 5 | `_ActionButtons` | Implemented |
| 7 | Footer ops-only / no bank | §3 region 6 | footer Text | Implemented |
| 8 | Tokens `#121212` / `#CCFF00` / `#FF3B30` | §3 region 7 | `KineticTokens` | Implemented |
| 9 | Receptionist read-only | AC-A2 / AC-B2 | `canWrite: canFulfillPayouts` | Implemented |
| 10 | EN\|AR + RTL | AC-D4 | EasyLocalization keys `payouts.*` | Implemented |

## §E2 residual

- Live Stitch screenshot + HTML parse **required** before BizDev **PASS**.
- Re-run with `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813` or inject `GOOGLE_STITCH_API_KEY`.
