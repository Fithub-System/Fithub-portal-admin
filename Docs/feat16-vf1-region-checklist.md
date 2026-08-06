# FEAT-16 VF1 — Region checklist (Stitch vs Flutter)

**Screen:** `216e0407184f4c39bd501ed436c1e88b` — Admin Overview Dashboard  
**Stitch source:** HTTP MCP `get_screen` 2026-08-03T19:33:10Z  
**Stitch assets:** `Docs/feat16-vf1-assets/stitch-216e0407-screenshot.png`, `stitch-216e0407.html`

| Region | Stitch (from HTML/MCP) | Flutter implementation | Δ |
|--------|------------------------|------------------------|---|
| Page BG | `#131313` | `KineticTokens.stitchBackground` | 0 |
| Rail width | `w-64` = 256px | `KineticTokens.railWidth` 256 | 0 |
| Rail brand | `#CCFF00` Lexend black | `home.shell.brand` lime w900 | Match |
| 6-rail IA | Home…Reports | `PortalShellDestinations` ×6 | Match (Install) |
| Header height | `h-16` = 64 | Container height 64 | 0 |
| Header eyebrow | ADMIN CONSOLE uppercase | `home.shell.admin_console` | Match |
| Main pad | `p-10` = 40 | `EdgeInsetsDirectional.all(40)` | 0 |
| Hero gap | `gap-8` = 32 | `SizedBox(width/height: 32)` | 0 |
| Section vertical | `space-y-10` = 40 | `SizedBox(height: 40)` | 0 |
| Occupancy card | `#1C1B1B`, `p-8`, `rounded-xl`, left `#4A8EFF` 4px | `LiveOccupancyGauge` | Match |
| Occupancy count | `text-5xl` blue | 48px `secondaryContainer` | ±Match |
| Occupancy bar | h-4 gradient → `#007BFF` | height 16, same gradient | 0 |
| Daily Yield | `#C3F400`, italic title, huge amount | `DailyYieldCard` | Layout match; amount `—` (no Backend) |
| Expiring table | headers + RENEW ALL | `ExpiringMembershipsCard` | Chrome match; empty body |
| Access Gate | dashed square + Ready | `AccessGatePanel` → scanner | Layout match; CTA opens FEAT-12 |
| Access Granted | lime ring + bar | shown when last scan approved | Match |
| Footer tiles | 4× `#0E0E0E` `p-6` | `OverviewFooterStats` | Layout match; values `—` |

## Side-by-side artifacts

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf1-assets/stitch-216e0407-screenshot.png` |
| Widget evidence | `test/feat16_vf1_overview_fidelity_test.dart` (region labels + Access Granted) |
| App raster (optional human) | Capture Home @ ≥1024px width after deploy; drop as `Docs/feat16-vf1-assets/app-overview-desktop.png` |

## Notes

- Cursor MCP `user-stitch` **not** injected; fetch via authenticated HTTP (`gcloud` OAuth + quota project). API-key-only `tools/call` returned **401**.
- AR twin id `167e03106e8c45c6b47b8ecb48116624` catalogued; EN layout remediated this PR (RTL mirror inherits Directionality).
