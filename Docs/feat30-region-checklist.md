# Region checklist — FEAT-30 Admin Payout Queue

**Stitch source:** HTTP MCP `get_screen` (2026-08-10) — EN `405663d1534848d2a96f1db4e76c35df` · AR `142d4cb868ff4aff8c040453bad737f9`.  
**MCP screenshots:** `Docs/feat30-assets/stitch-en-mcp.png` · `stitch-ar-mcp.png`  
**App screenshots:** `Docs/feat30-assets/app-en-payout-queue.png` · `app-ar-payout-queue.png` (pre-remedia chrome; order proven by widget Y-assert 2026-08-11)  
**Brand Lock DS:** `assets/12737976743993098844`  
**Remedia:** 2026-08-11 — vertical order fixed to Stitch SoT (Header → KPI → Filters → Table).

| # | Region | Spec / Stitch | Flutter | Status |
|---|--------|---------------|---------|--------|
| 1 | Payouts rail destination | Inventory: Payouts active | `PortalShellDestinations.payouts` + rail/bar | Implemented |
| 2 | Header title + no-PSP subtitle | Stitch header | `_Header` | Implemented |
| 3 | KPI strip — Pending / Paid today / Rejected today | **Stitch order: after header** | `PayoutKpiStrip` | Implemented |
| 4 | Filter chips All/Pending/Paid/Rejected | **Stitch order: after KPIs** | `PayoutFilterChips` | Implemented |
| 5 | Table Coach·Amount·Status·Requested·Actions | Stitch table | `PayoutQueueTable` | Implemented |
| 6 | Mark paid (lime) / Reject (peak coral) | Stitch actions | `_ActionButtons` | Implemented |
| 7 | Footer ops-only / no bank | Stitch footer | footer Text | Implemented |
| 8 | Tokens `#121212` / `#CCFF00` / `#FF3B30` | Brand Lock | `KineticTokens` | Implemented |
| 9 | Receptionist read-only | AC-A2 / AC-B2 | `canWrite: canFulfillPayouts` | Implemented |
| 10 | EN\|AR + RTL | AC-D4 | EasyLocalization keys `payouts.*` | Implemented |

## §E2 status

- MCP screenshots present (side-by-side artifacts ready).
- Vertical region order matches live Stitch SoT: **Header → KPI → Filters → Table** (remedia 2026-08-11 in `admin_payout_queue_screen.dart`).
- Spec Cards region tables amended to KPI-then-filters (Stitch artboard wins over earlier FSD §3 filter-first listing).
- Widget-test harness `toImage` hangs (no reliable screenshot writer); remedia order covered by `Stitch vertical order Header → KPI → Filters → Table` Y-position assertion in `test/feat30_admin_payout_queue_test.dart`. Existing app PNGs retained for token/copy chrome.
