# FEAT-01 Portal — Access Scanner Verification Audit

**Date:** 2026-07-20  
**Branch:** `feature/portal-feat01-access-scanner`  
**Agent:** Portal Admin  
**Spec:** FEAT-01 AC1 (offline session) + AC2 (offline scan) + §3 Access Scanner UI  
**Manual Test Guide:** [PHASE-FEAT-01-manual-test.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/manual-tests/PHASE-FEAT-01-manual-test.md) *(ships at FEAT-01 COMPLETE — link per [standards/manual-test-guides.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/standards/manual-test-guides.md))*

## Stitch

| Field | Value |
|-------|--------|
| Project | `13435235862240753621` |
| Screen | **Access Scanner** (camera + neon target grid + success banner) |
| Screen id | `pending_stitch_mcp_verification` — confirm via Stitch MCP `list_screens` when `GOOGLE_STITCH_API_KEY` is configured (Cursor catalog omits `user-stitch`; same fallback as Phase 1.2-R / FEAT-05) |
| Tokens | FEAT-01 §3 + Kinetic Monolith: `#121212` charcoal, `#CCFF00` lime grid, green slide-down success with Active badge |

## Acceptance

| AC | Result | Evidence |
|----|--------|----------|
| AC1 Offline session restore | PASS (client) | `AuthBloc._onStarted` falls back to `readCachedProfile()` from `flutter_secure_storage` when Supabase session missing or resolve fails; `AuthAuthenticated(restoredFromCache: true)`; SafeMode banner unchanged (24px zinc, EN/AR) |
| AC2 Offline scan branch | PASS (client) | Reuses `QrSignatureValidator` + `ScanRepository.processOfflineScan` → Drift queue + occupancy bump; scanner wires result to `DashboardCubit.reportScanResult` |
| Access Scanner UI | PASS (client) | `cleanarch access_scanner -c`; `AccessScannerScreen` + `mobile_scanner` camera + neon target overlay + green success banner |
| Member roster sync | SCAFFOLD (Backend dep) | `SyncMemberRosterUseCase` → Supabase `athletes` SELECT → `AppDatabase.upsertMembers`; surfaces `access_scanner.roster.error.policy` until Backend `feature/backend-feat01-qr-member-roster` merges |
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

## Backend dependency

Portal member roster sync **blocked** until Backend ships employee SELECT athletes policy:

1. Branch: `feature/backend-feat01-qr-member-roster`
2. Contract doc: `Fithub-backend/docs/feat01-qr-loop-backend.md` *(Backend agent)*
3. SQL verify: `supabase/tests/feat01_qr_roster_verify.sql`
4. Until merged: roster sync shows localized policy error; offline scan works with manually seeded / previously cached `LocalMembers`

## Tests

```bash
flutter test
```

Includes `test/feat01_access_scanner_test.dart` (Stitch citation, roster use case, AC1 cache restore) + carry-forward `phase_1_2_offline_contract_test.dart`.

## Verdict

**PASS (client)** — Access Scanner UI + camera + offline scan wiring + AC1 secure-session restore + EN/AR.  
**Residual:** Stitch screen id verification via MCP; Backend athlete roster RLS for live sync; end-to-end smoke Athlete QR → Portal offline scan → reconnect (Phase 1.3).

**Do NOT merge** until BizDev Audit PASS.
