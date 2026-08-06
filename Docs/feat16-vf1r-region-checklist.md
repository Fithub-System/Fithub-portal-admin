# FEAT-16 VF1-R — Region checklist (§4.1 content)

**Screen:** `216e0407184f4c39bd501ed436c1e88b` — Admin Overview Dashboard  
**Stitch source:** HTTP MCP `get_screen` 2026-08-04T08:29:27Z  
**Stitch assets:** `Docs/feat16-vf1r-assets/`  
**Layout baseline:** `Docs/feat16-vf1-region-checklist.md` (VF1 PASS)

| Region | Stitch artboard | Flutter (unbound) | §4.1 |
|--------|-----------------|-------------------|------|
| Daily Yield amount | `$12,482` | fixture `$12,482` | PASS |
| Daily Yield delta | `+14.2% vs yesterday` | fixture | PASS |
| Expiring rows | Marcus Thorne + Elena Rodriguez | same fixture rows | PASS |
| Access Gate waiting | Waiting for scan… + Ready | same | PASS (VF1) |
| Access Granted sample | John Smith · `#KM-88219` · bar | fixture always (until reject / live) | PASS |
| Footer tiles | 2,841 / 42 / 12 / 0 | fixtures | PASS |
| Live Occupancy | 80/100 sample | **live-bound** | keep FEAT-04 |
| Open scanner CTA | → Check-in Gate | FEAT-12 | keep |

## Notes

- §4.1 confirmed: Yield / Expiring / footer / Access Granted sample always ship fixtures — never blank / bare `—` shells.
- Cursor MCP `user-stitch` absent; fetch via HTTP OAuth (`gcloud` + `fithub-503813`).
- AR twin `167e03106e8c45c6b47b8ecb48116624` catalogued (`Docs/feat16-vf1r-assets/stitch-167e0310-meta.json`).
