# FEAT-01 Portal — Access Scanner Verification Audit

**Date:** 2026-07-20 (Stitch residual closed 2026-07-21 — Hardening Gate)  
**Branch:** `feature/portal-hardening-stitch-attendance`  
**Agent:** Portal Admin  
**Spec:** FEAT-01 AC1 (offline session) + AC2 (offline scan) + §3 Access Scanner UI  
**Manual Test Guide:** [PHASE-FEAT-01-manual-test.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/manual-tests/PHASE-FEAT-01-manual-test.md)  
**Smoke:** [FEAT-01-smoke-test.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/manual-tests/FEAT-01-smoke-test.md)

## Stitch

| Field | Value |
|-------|--------|
| Project | `13435235862240753621` |
| Screen | **Access Scanner** UI built to FEAT-01 §3 + Kinetic Monolith |
| Screen id | `216e0407184f4c39bd501ed436c1e88b` — **Admin Overview Dashboard** companion |
| Catalog verify | Stitch MCP `list_screens` on 2026-07-21: **no screen titled Access Scanner** among 80 screens. Closest: Admin Overview Dashboard, Member Management, Staff Management. Pending id resolved to Admin Overview companion. |
| Tokens | FEAT-01 §3 + Kinetic: `#121212` charcoal, `#CCFF00` lime grid, green slide-down success with Active badge |

## Acceptance

| AC | Result | Evidence |
|----|--------|----------|
| AC1 Offline session restore | PASS (client) | `AuthBloc._onStarted` falls back to `readCachedProfile()` from `flutter_secure_storage` when Supabase session missing or resolve fails; `AuthAuthenticated(restoredFromCache: true)`; SafeMode banner unchanged (24px zinc, EN/AR) |
| AC2 Offline scan branch | PASS (client) | Reuses `QrSignatureValidator` + `ScanRepository.processOfflineScan` → Drift queue + occupancy bump; same-UTC-day soft reject; scanner wires to `DashboardCubit.reportScanResult` |
| Same-day unique (Hardening) | PASS (client) | Local soft reject `Already checked in today.`; offline sync treats PostgREST `23505` as idempotent success |
| Access Scanner UI | PASS (client) | `cleanarch access_scanner -c`; `AccessScannerScreen` + `mobile_scanner` camera + neon target overlay + green success banner |
| Member roster sync | PASS | `SyncMemberRosterUseCase` → Supabase `athletes` SELECT → `AppDatabase.upsertMembers` (Backend FEAT-01 roster merged) |
| Admin + Receptionist only | PASS | Existing FEAT-02 auth gate; scan tab in `PortalHomeShell` for authenticated portal roles only |
| EN/AR i18n | PASS | `access_scanner.*` keys in `assets/translations/en.json` + `ar.json` |
| AC-C2 No service_role | PASS | Supabase anon + user JWT only; no service_role in Portal |

## Architecture

- Scaffold: `cleanarch access_scanner -c` (Cubit — scan + roster sync status)
- Per-feature DI: `lib/features/access_scanner/injection_container.dart` → root facade
- Carry-forward: `ScanRepository`, `QrSignatureValidator`, Drift `LocalMembers`, Phase 1.3 `OfflineSyncCubit`
- Ports: `MemberRosterRepository` / `MemberRosterRemoteDataSource` / `MemberRosterLocalDataSource`
- Adapter: `MemberRosterSupabaseRemoteDataSource` (PostgREST SELECT `athletes`)
- Presentation does not import `supabase_flutter` (FEAT-04)

## Tests

```bash
flutter test
```

Includes `test/feat01_access_scanner_test.dart` (Stitch citation, roster use case, AC1 cache restore) + `phase_1_2_offline_contract_test.dart` (same-day soft reject) + carry-forward Phase 1.3 suite.

## Verdict

**PASS (client)** — Access Scanner UI + camera + offline scan wiring + AC1 + Stitch companion citation (2026-07-21) + same-day attendance handling.

**Do NOT merge** until BizDev Audit PASS (Hardening Gate authorizes merge when tests green).
