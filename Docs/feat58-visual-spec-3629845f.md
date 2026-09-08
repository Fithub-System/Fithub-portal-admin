# Visual Spec Card — FEAT-58 Access Scanner ready (G1 chrome)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-58 |
| Stitch project | `13435235862240753621` |
| Screen id (EN) | `3629845f7f1e402697f46cf5575e86da` |
| Screen id (AR) | `bec9356e2cb941798e66fa804ac78854` |
| Stitch title | Check-in Gate / Access Scanner |
| Platform | DESKTOP (web Admin) |
| MCP tools used | None this session (`user-stitch` unavailable) — reuse FEAT-16 VF4 fetch |
| Prior assets | `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png` · AR twin `stitch-bec9356e-ar-screenshot.png` |
| Fetched at (UTC) | Reuse 2026-08-03 VF4 pull |
| Author agent | Portal Admin Agent |

---

## Delta vs FEAT-16 VF4 (this FEAT)

| Region | Stitch / prior | FEAT-58 change |
|--------|----------------|----------------|
| Scan viewport pending | Opaque “waiting” until first barcode (bug) | Opaque pending only until **stream start**; copy = Allow camera / Enter code |
| Ready HUD | `Ready - Waiting for Scan` label | Shown **after** `cameraReady`; **no** opaque blocker fill |
| Manual entry | Debug-only FAB | Production FAB when pending/error (`Enter code`) |
| Permission | Unspecified | Helper: camera for check-in; browser may remember site permission |
| Leave | Controller dispose only | Explicit `stop()` then `dispose()` (tracks released; no fake revoke) |

---

## Frame (unchanged from G1)

| Field | Value |
|-------|-------|
| Page background | `#131313` |
| Gate panel | `#1C1B1B` + lime glow |
| Viewport | `#1A1A1A` + lime/20 border |
| Lime accent | `#C3F400` |
| Ready label | Inter ~11px uppercase tracking ~0.4em lime |

Screenshot reference: `Docs/feat16-vf4-assets/stitch-3629845f-screenshot.png`  
AR: `Docs/feat16-vf4-assets/stitch-bec9356e-ar-screenshot.png`  
Full region map: `Docs/feat16-vf4-visual-spec-3629845f.md`

---

## Flutter targets

| Chrome | Widget / key |
|--------|----------------|
| Pending overlay | `Key('access-scanner-pending-overlay')` |
| Ready label | `Key('access-scanner-ready-label')` |
| Manual CTA | `Key('access-scanner-manual-entry-cta')` |
| Host + permission note | `AccessScannerFocusHost` |

---

## Side-by-side notes

- Stitch still owns Ready label typography when stream is live.
- Pending state is product chrome (actionable) — not a Stitch artboard variant; keep Kinetic tokens.
- No Permissions-Policy / fake session-only revoke UI.
