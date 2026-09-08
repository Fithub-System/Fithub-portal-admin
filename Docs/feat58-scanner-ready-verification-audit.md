# FEAT-58 — Portal Access Scanner ready — Verification Audit

**Date:** 2026-09-08  
**Branch:** `feature/portal-feat58-scanner-ready`  
**Base:** `origin/dev`  
**FSD:** `Fithub-documentation/specs/FEAT-58-PORTAL-SCANNER-READY.md` (LOCKED)  
**Kickoff:** `Fithub-documentation/kickoff-feat58-portal-scanner-ready.md`  
**Issue:** [#37](https://github.com/Fithub-System/Fithub-portal-admin/issues/37)  
**Stitch:** G1 EN `3629845f7f1e402697f46cf5575e86da` · AR `bec9356e2cb941798e66fa804ac78854`  
**Visual Spec Card:** `Docs/feat58-visual-spec-3629845f.md`

## Status

**Provisional PASS** — Portal Admin Agent self-check. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`. **Do not merge.**

## Root cause (fixed)

Waiting overlay stayed opaque until `cameraReady`, and ready was only set inside `_onBarcodeDetect`. Admin saw endless loading with no path unless a QR decoded first.

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Mark camera ready on stream start | PASS | `AccessScannerScreen` listens to `MobileScannerController`; `isRunning` → `markCameraReady()` (not barcode-only) |
| AC-A2 Error chrome + production manual CTA | PASS | `markCameraError()` + `showManualEntryCta`; FAB `access-scanner-manual-entry-cta` not `kDebugMode`-only |
| AC-A3 Pending actionable copy | PASS | Gate pending overlay `access_scanner.camera.pending` + Enter code; permission note |
| AC-A4 Stitch G1 EN+AR + RTL | PASS | Tokens / screen / focus host; AR widget test |
| AC-A5 Online/offline validate unchanged | PASS | No changes to `ProcessQrScanUseCase` / attendance path |
| AC-B1 stop/dispose on leave | PASS | `dispose` → `stop()` then `dispose()` on controller |
| AC-B2 Honest permission copy | PASS | `access_scanner.camera.permission_note` (EN+AR); no fake revoke |
| AC-B3 No invented Permissions-Policy | PASS | Docs/UI only; no policy header changes |
| AC-C1 Branch from `origin/dev` | PASS | `feature/portal-feat58-scanner-ready` |
| AC-C2 Feature stays in `access_scanner` (+ gate) | PASS | Screen / cubit / `check_in_gate_layout` / focus host |
| AC-C3 No `service_role`; tests | PASS | Unit + widget tests in `test/feat58_scanner_ready_test.dart` |

## Tests

```bash
flutter test \
  test/feat58_scanner_ready_test.dart \
  test/feat01_access_scanner_test.dart \
  test/feat12_access_scanner_home_test.dart \
  test/feat16_vf4_access_g1_fidelity_test.dart
```

## Manual test

- Docs repo: `Fithub-documentation/manual-tests/PHASE-FEAT-58-manual-test.md`
- Portal draft copy: `Docs/PHASE-FEAT-58-manual-test-DRAFT.md` (BizDev may sync if docs lag)

## Residuals / blockers

1. Live Admin smoke on web (Allow camera → overlay clears without QR; leave releases tracks).
2. Stitch MCP (`user-stitch`) unavailable this session — Visual Spec Card cites locked G1 + FEAT-16 VF4 assets; no fresh pixel pull.
3. Browser still cannot revoke origin camera permission on leave (by design — documented).
4. **Do not merge** without BizDev Audit PASS.

## Verification Audit (agent)

- [x] cameraReady on stream start — **Verification Audit:** controller listener.
- [x] Waiting overlay clears without QR — **Verification Audit:** gate overlay + FEAT-58 widget test.
- [x] Production manual CTA pending/error — **Verification Audit:** `showManualEntryCta` + FAB key.
- [x] stop/dispose on leave — **Verification Audit:** `_stopAndDisposeController`.
- [x] Honest permission copy EN/AR — **Verification Audit:** translation keys + focus host.
- [x] Stitch G1 EN+AR cited — **Verification Audit:** tokens + tests.
- [x] Tests — **Verification Audit:** `feat58_scanner_ready_test.dart`.
