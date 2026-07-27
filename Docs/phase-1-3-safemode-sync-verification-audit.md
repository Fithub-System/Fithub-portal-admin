# Phase 1.3 Portal — SafeMode Offline Sync Verification Audit

**Date:** 2026-07-19  
**Branch:** `feature/portal-1.3-safemode-sync`  
**Agent:** Portal Admin  
**Plan:** Phase 1.3 Secure Offline Storage & SafeMode Architecture  

## Scope delivered

| Item | Result | Evidence |
|------|--------|----------|
| Drift `LocalMembers` / `LocalAttendanceQueue` / `LocalGymCache` | PASS (carry-forward hardened) | `lib/core/database/`; `markAttendanceSynced` transactional write |
| Network observer + SafeMode banner 24px zinc, localized | PASS | `ConnectivityService` + `SafeModeBanner`; `connectivity.safe_mode.banner` EN/AR; existing UI token tests |
| Offline Sync Engine — bulk upsert on reconnect | PASS (client) | `cleanarch offline_sync -c`; `OfflineSyncCubit` listens to connectivity; Supabase upsert `onConflict: id` |
| Idempotent / no dupes | PASS (unit) | Same UUID PK upsert; local `is_synced` gate; `phase_1_3_offline_sync_test.dart` |
| EasyLocalization + Accept-Language | PASS (unchanged) | FEAT-03 carry-forward; sync error keys under `connectivity.sync.*` |
| Gyms occupancy UPDATE RLS | REPORTED to Backend | Client surfaces `OfflineSyncOccupancyRlsFailure` / `connectivity.sync.error.occupancy_rls` — **no Portal-invented policies** |

## Architecture

- Scaffold: `cleanarch offline_sync -c` (Cubit — reconnect-driven sync status)
- Per-feature DI: `lib/features/offline_sync/injection_container.dart` → root facade
- Ports: `OfflineSyncRepository` / `OfflineSyncLocalDataSource` / `OfflineSyncRemoteDataSource`
- Adapter: `OfflineSyncSupabaseRemoteDataSource` (PostgREST upsert + gyms UPDATE)
- Presentation does not import `supabase_flutter`
- Wired from authenticated shell (`AppRouter`) alongside `ConnectivityCubit` / `DashboardCubit`

## Sync contract

1. Collect Drift rows where `is_synced == false` for the employee tenant  
2. Bulk `upsert` into `public.attendance_logs` with `onConflict: id` (idempotent)  
3. Transactionally mark those local ids `is_synced = true`  
4. Push Drift-cached `current_occupancy` to `gyms` UPDATE  
5. If step 4 fails permission/RLS → emit Backend handoff status; keep attendance flush

## Backend handoff (do not invent policies)

1. **Gyms UPDATE:** Migration `20260718222000_gyms_occupancy_update_rls.sql` exists in Backend repo — Backend agent must verify it is **applied on live** Supabase. Portal reports denial via `connectivity.sync.error.occupancy_rls` when UPDATE fails.  
2. **Attendance INSERT grant:** Catalog currently grants `SELECT` on `attendance_logs` only (`20260718220000_employees_self_select_grants.sql`). Sync upsert likely needs **`GRANT INSERT` (and possibly UPDATE) on `attendance_logs` TO authenticated** while RLS `tenant_isolation_policy` remains. Portal maps permission failures to `connectivity.sync.error.attendance_grant` — **Backend must ship the GRANT**; Portal will not invent SQL.

## Tests

```bash
flutter test
```

Includes `test/phase_1_3_offline_sync_test.dart` (bulk mark-synced, idempotent second pass, occupancy RLS soft-report, cubit reconnect).

## Verdict

**PASS (client)** — Offline Sync Engine + hardened Drift/SafeMode carry-forward + localized banner.  
**Residual:** live Backend apply of gyms UPDATE RLS + attendance INSERT GRANT before e2e reconnect smoke.  

**Do NOT merge** until BizDev Audit PASS.
