# FEAT-12 Portal Access Scanner under Home (Install I2) — Verification Audit

**Date:** 2026-07-31  
**Branch:** `feature/portal-feat12-access-scanner`  
**FSD:** `Fithub-documentation/specs/FEAT-12-ACCESS-SCANNER-HOME.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat12-access-scanner.md`  
**Manual:** `Fithub-documentation/manual-tests/PHASE-FEAT-12-manual-test.md`  
**Stitch project:** `13435235862240753621`

## Status

**Provisional PASS** — Portal Admin Agent self-check. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

**Out of scope (not claimed):** I3 Gym Settings, I4 Add Member, checkout flow polish (P1 residual).

## Stitch citations (§3)

| Surface | Stitch id | Evidence |
|---------|-----------|----------|
| Access Scanner / Check-in Gate (EN) | `3629845f7f1e402697f46cf5575e86da` | `KineticTokens.stitchAccessScannerScreenId`; `AccessScannerScreen.stitchScreenId`; Home CTA + focus host |
| Access Scanner AR | `bec9356e2cb941798e66fa804ac78854` | `KineticTokens.stitchAccessScannerScreenIdAr`; `AccessScannerScreen.stitchScreenIdAr` |
| Home Overview (unchanged) | `216e0407184f4c39bd501ed436c1e88b` | `KineticTokens.stitchOccupancyScreenId` / Live Occupancy |

**Entry:** Home → Open scanner CTA / panel → focus mode. **Not** a top-level rail destination.

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Entry only under Home; FEAT-11 six-destination rail preserved | PASS | `PortalShellDestinations.destinationCount = 6`; rail/bar omit Scan; `_scannerFocus` + `HomeAccessScannerCta` under `_DashboardDestination` |
| AC-A2 Code/audit cites Stitch EN+AR | PASS | Tokens + screen constants + this audit |
| AC-A3 EN/AR + RTL | PASS | `home.scanner.*`, `access_scanner.title` Check-in Gate; AR CTA widget test |
| AC-B1 Reuse process QR → attendance upsert | PASS | Existing `AccessScannerCubit` / `ProcessQrScanUseCase` (FEAT-01/09); DI unchanged at `app_router` AuthenticatedShell |
| AC-B2 Reject path shows reason | PASS | Existing reject banner `access_scanner.scan.rejected` + `rejectReason` on `AccessScannerScreen` |
| AC-B3 Power Score optional | N/A | Not on `ScanProcessResult` today — no regression; membership status badge retained |
| AC-C1 Zinc offline banner space | PASS | `SafeModeBanner` remains above focus host and shell body |
| AC-C2 SafeMode / Drift validate preserved | PASS | No changes to offline sync / process QR path |
| AC-D1 Extend `access_scanner` / `home`; new folders only via cleanarch | PASS | Extended existing features; widgets under `home/presentation/widgets/`; **no new** `lib/features/*` folder |
| AC-D2 Branch name | PASS | `feature/portal-feat12-access-scanner` |
| AC-D3 No `service_role` | PASS | No Backend / secrets changes |

## Install wiring

| Before (FEAT-11) | After (FEAT-12 I2) |
|------------------|--------------------|
| `access_scanner` retained but off-rail | Home CTA panel → focus Check-in Gate |
| Companion Overview Stitch id for scanner | Locked G1 EN+AR ids |
| Dashboard last-scan text only | CTA + focus scanner + occupancy chip + last-scan text |

## Tests

```bash
flutter test test/feat12_access_scanner_home_test.dart test/feat01_access_scanner_test.dart test/feat11_shell_match_stitch_test.dart
```

- `test/feat12_access_scanner_home_test.dart` — G1 Stitch EN+AR, six destinations, Home CTA EN/AR, focus host close + occupancy chip
- `test/feat01_access_scanner_test.dart` — Stitch citation updated to G1 ids
- `test/feat11_shell_match_stitch_test.dart` — rail IA regression

## Manual test reference

- `Fithub-documentation/manual-tests/PHASE-FEAT-12-manual-test.md`
- Provider guide §I2

## Residuals / blockers

1. Live Admin smoke on PHASE-FEAT-12 steps 1–5 (human / BizDev).
2. Stitch MCP unavailable in agent session — ids cited from locked FSD §3 / brief pack (not live pixel pull).
3. Power Score on member card deferred until domain result exposes it.
4. Do **not** merge without BizDev Audit PASS. Do **not** start I3/I4 in this PR.

## Verification Audit (agent)

- [x] Home → Open scanner (not rail) — **Verification Audit:** `HomeAccessScannerCta` + `_scannerFocus`.
- [x] Stitch G1 EN+AR cited — **Verification Audit:** `KineticTokens` + screen constants.
- [x] Online / reject / SafeMode paths reuse FEAT-01 — **Verification Audit:** no process-QR rewrite.
- [x] Six-destination rail preserved — **Verification Audit:** `PortalShellDestinations` + FEAT-11 tests.
- [x] EN/AR i18n — **Verification Audit:** `en.json` / `ar.json` `home.scanner.*`.
- [x] Tests — **Verification Audit:** `feat12_access_scanner_home_test.dart`.
