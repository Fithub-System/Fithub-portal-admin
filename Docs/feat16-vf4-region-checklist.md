# FEAT-16 VF4 — Access G1 Region Checklist

**Stitch source:** HTTP MCP `get_screen` 2026-08-03T21:00:18Z  
**Stitch assets:** `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png`, `stitch-3629845f.html`  
**Spec Card:** `Docs/feat16-vf4-visual-spec-3629845f.md`

| Region / element | Stitch | Flutter | Δ px / notes |
|------------------|--------|---------|--------------|
| Page BG | `#131313` | `KineticTokens.stitchBackground` | 0 |
| 6-rail IA | Home active; no Scan | `PortalShellDestinations` ×6; focus keeps rail | match |
| Header brand | `KINETIC MONOLITH` | `access_scanner.gate.brand` | match |
| Eyebrow | `ADMIN CONSOLE // SECURE ACCESS GATE` | `access_scanner.gate.eyebrow` | match |
| Scanner panel + glow | `#1C1B1B` + lime glow | `CheckInGateScanner` panel | match |
| Viewport waiting | QR + Ready-Waiting pulse | overlay on FEAT-01 scanner | §4.1 |
| HUD lat/lng | 34.0522 / 118.2437 | fixtures | §4.1 |
| Confirm CTA idle | CONFIRM CHECK-IN lime | `check-in-gate-confirm` | match |
| Confirm granted | ACCESS GRANTED blue | success state | match |
| System ID / Encryption | 098-KM-X · AES-256 | fixtures | §4.1 |
| Peak / Avg Dwell / Guests | 94% · 68 MIN · 04 | fixtures | §4.1 |
| Live Occupancy ring | 42 / 100 LIMIT | live or fixture | §4.1 |
| Last member | Marcus Henderson · Active · 780 | fixture or live success | §4.1 |
| System Log | 4 GATE_* lines | fixtures | §4.1 |
| Close control | product | `access-scanner-focus-close` | allowed delta |

## Side-by-side

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png` |
| AR twin screenshot | `Docs/feat16-vf4-assets/stitch-bec9356e-ar-screenshot.png` |
| Widget evidence | `test/feat16_vf4_access_g1_fidelity_test.dart` |

## Notes

- Cursor MCP `user-stitch` **not** injected; fetch via authenticated HTTP (`gcloud` OAuth + quota project).
- §4.1 confirmed: waiting/ready/granted + Marcus / stats / system log / coords always ship fixtures — never blank/`—` shells.
- FEAT-12 focus host + FEAT-01 camera/manual path preserved in embedded scanner viewport.
