# FEAT-01 Portal — Access Scanner Verification Audit

**Date:** 2026-07-20 (Stitch residual closed 2026-07-21 — Hardening Gate)  
**Updated:** 2026-07-30 — P0 online `attendance_logs` INSERT (FEAT-09 award unblock)  
**Branch:** `feature/portal-feat01-attendance-insert`  
**Agent:** Portal Admin  
**Spec:** FEAT-01 AC1 (offline session) + AC2 (offline scan) + §3 Access Scanner UI + §4.A `attendance_logs`  
**Manual Test Guide:** [PHASE-FEAT-01-manual-test.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/manual-tests/PHASE-FEAT-01-manual-test.md)  
**Smoke:** [FEAT-01-smoke-test.md](https://github.com/Fithub-System/Fithub-documentation/blob/dev/manual-tests/FEAT-01-smoke-test.md)  
**Remediation:** `kickoff-feat09r-operator-fail.md` P0-A (Portal gap)

## Stitch

| Field | Value |
|-------|--------|
| Project | `13435235862240753621` |
| Screen | **Access Scanner** UI built to FEAT-01 §3 + Kinetic Monolith |
| Screen id | `216e0407184f4c39bd501ed436c1e88b` — **Admin Overview Dashboard** companion |
| Catalog verify | Stitch MCP `list_screens` on 2026-07-21: **no screen titled Access Scanner** among 80 screens. Closest: Admin Overview Dashboard, Member Management, Staff Management. Pending id resolved to Admin Overview companion. |
| Tokens | FEAT-01 §3 + Kinetic: `#121212` charcoal, `#CCFF00` lime grid, green slide-down success with Active badge |

## Gap → fix (2026-07-30 P0)

| Finding | Evidence | Fix |
|---------|----------|-----|
| Live `attendance_logs` count **0** after Portal scan; `gyms.current_occupancy` **1**; FEAT-09 award never fired | BizDev + Backend SQL proof 2026-07-30; Backend award trigger healthy on manual INSERT | Online Access Scanner success now flushes Drift queue → Supabase `attendance_logs` upsert **before** occupancy push |
| Root cause in code | `ProcessQrScanUseCase` → only `ScanRepository.processOfflineScan` (local enqueue + Drift occupancy). `OfflineSyncCubit` flushed on reconnect/start only — **not** after each online scan | `ProcessQrScanUseCase(online: true)` calls `SyncPendingAttendanceUseCase` immediately after approved local write. Adapter: `OfflineSyncSupabaseRemoteDataSource.upsertAttendanceLogs` (`tenant_id` + `athlete_id` + `checked_in_at`) |
| Same-day unique / soft-reject | Unchanged | Local soft reject `Already checked in today.`; cloud `23505` still idempotent success on reconnect sync |

## Acceptance

| AC | Result | Evidence |
|----|--------|----------|
| AC1 Offline session restore | PASS (client) | `AuthBloc._onStarted` falls back to `readCachedProfile()` from `flutter_secure_storage` when Supabase session missing or resolve fails; `AuthAuthenticated(restoredFromCache: true)`; SafeMode banner unchanged (24px zinc, EN/AR) |
| AC2 Offline scan branch | PASS (client) | Reuses `QrSignatureValidator` + `ScanRepository.processOfflineScan` → Drift queue + occupancy bump; same-UTC-day soft reject; scanner wires to `DashboardCubit.reportScanResult` |
| **Online check-in → `attendance_logs` INSERT** | PASS (client) | `AccessScannerCubit.onQrDetected` passes `online: _isOnline()`; `ProcessQrScanUseCase` flushes via `SyncPendingAttendanceUseCase` → PostgREST upsert `attendance_logs` then `gyms.current_occupancy`. Occupancy is **not** the only cloud write. |
| Same-day unique (Hardening) | PASS (client) | Local soft reject `Already checked in today.`; offline sync treats PostgREST `23505` as idempotent success |
| Access Scanner UI | PASS (client) | `cleanarch access_scanner -c`; `AccessScannerScreen` + `mobile_scanner` camera + neon target overlay + green success banner |
| Member roster sync | PASS | `SyncMemberRosterUseCase` → Supabase `athletes` SELECT → `AppDatabase.upsertMembers` (Backend FEAT-01 roster merged) |
| Admin + Receptionist only | PASS | Existing FEAT-02 auth gate; scan tab in `PortalHomeShell` for authenticated portal roles only |
| EN/AR i18n | PASS | `access_scanner.*` keys in `assets/translations/en.json` + `ar.json` — no new user-facing strings this fix |
| AC-C2 No service_role | PASS | Supabase anon + user JWT only; no service_role in Portal |

## Architecture

- Scaffold: `cleanarch access_scanner -c` (Cubit — scan + roster sync status)
- Per-feature DI: `lib/features/access_scanner/injection_container.dart` → root facade
- Carry-forward: `ScanRepository`, `QrSignatureValidator`, Drift `LocalMembers`, Phase 1.3 `OfflineSyncCubit`
- **Online path:** `ProcessQrScanUseCase` + `SyncPendingAttendanceUseCase` + `OfflineSyncRepositoryImpl` (attendance upsert **then** occupancy UPDATE)
- Ports: `MemberRosterRepository` / `MemberRosterRemoteDataSource` / `MemberRosterLocalDataSource`
- Adapter: `MemberRosterSupabaseRemoteDataSource` (PostgREST SELECT `athletes`)
- Presentation does not import `supabase_flutter` (FEAT-04)

## Tests

```bash
flutter test test/feat01_online_attendance_insert_test.dart test/feat01_access_scanner_test.dart test/phase_1_2_offline_contract_test.dart test/phase_1_3_offline_sync_test.dart
```

Includes:
- `test/feat01_online_attendance_insert_test.dart` — online flush called; offline skip; reject skip; SafeMode on upsert failure; same-day soft reject
- `test/feat01_access_scanner_test.dart` — Stitch citation, roster use case, AC1 cache restore
- `phase_1_2_offline_contract_test.dart` — same-day soft reject
- Phase 1.3 suite — reconnect bulk upsert still intact

## Residuals (out of scope — do not block this PR)

| Residual | Owner | Notes |
|----------|-------|-------|
| Occupancy refresh → 0 | Portal P1-A | Dashboard may overwrite cloud with Drift 0 on refresh — separate from attendance INSERT |
| Members roster empty until session login | Portal P1-C | Roster sync load-on-open — separate |
| No Athlete checkout in M1 | Product | FEAT-01 is check-in / same-day focused |

## Verdict

**PASS (client)** — Access Scanner online check-in now INSERTs/upserts `attendance_logs` so FEAT-09 `trg_award_power_score_on_checkin` can fire. Offline Drift queue + reconnect sync unchanged.

**Do NOT merge** until BizDev Audit PASS.
