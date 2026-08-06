# FEAT-18 — Class Manager Verification Audit (Portal)

**Branch:** `feature/portal-feat18-class-manager`  
**FSD:** `Fithub-documentation/specs/FEAT-18-PORTAL-CLASSES.md` (**LOCKED**)  
**Backend:** BizDev PASS — PR [#21](https://github.com/Fithub-System/Fithub-backend/pull/21) · contract `Fithub-backend/docs/feat18-class-sessions-backend.md`  
**Issue:** https://github.com/Fithub-System/Fithub-backend/issues/20  
**Date:** 2026-08-06  
**Agent:** Portal Admin Agent

---

## Scaffold

| Item | Value |
|------|-------|
| cleanarch | `cleanarch class_sessions -c --no-git` (Cubit — matches memberships CRUD convention; kit `-b` default overridden by local pattern) |
| DI | `registerClassSessionsDependencies` → root `InjectionContainer` |
| Writes | `rpc('upsert_class_session', …)` only — no table INSERT/UPDATE |
| service_role | None |
| supabase_flutter in presentation | None (data source only) |

---

## Acceptance Criteria

### US-A — Staff views class schedule

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Tenant-scoped list via RLS | PASS (client) | SELECT `class_sessions` ordered by `starts_at`; RLS stamps tenant |
| AC-A2 Cites Stitch EN+AR | PASS | `ClassManagerScreen.stitchScreenIdEn/Ar` + Visual Spec Card |
| AC-A3 Coming soon removed from Classes | PASS | `PortalHomeShell` → `ClassManagerScreen` (not `ClassesComingSoonPage`) |
| AC-A4 No freehand rail / nav | PASS | `PortalShellDestinations` unchanged (6 destinations) |

### US-B — Admin create / edit

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Admin write via RPC | PASS (client) | `ClassSessionsSupabaseRemoteDataSource.upsertSession` → `upsert_class_session` |
| AC-B2 Receptionist SELECT only | PASS (client) | `canManageClassSessions` / `canWrite: false` hides Schedule New + disables Create; Backend still denies |
| AC-B3 Same Stitch artboard form | PASS | Inline `ClassSessionFormPanel` on Class Manager |
| AC-B4 No Athlete booking / waitlist | PASS | Attendee chrome fixtures only |
| AC-B5 Soft-cancel | PASS | Detail menu → `status: cancelled` via RPC |

---

## Visual Fidelity §E2

| Item | Result |
|------|--------|
| Visual Spec Card | `Docs/feat18-visual-spec-40cc7e5d.md` |
| Region checklist | `Docs/feat18-class-manager-region-checklist.md` |
| Stitch MCP fetch | HTTP `get_screen` (EN+AR) → `Docs/feat18-assets/` |
| Side-by-side | Stitch PNGs + widget-test region evidence |

---

## i18n / RTL

| Item | Result |
|------|--------|
| EN/AR keys | `assets/translations/en.json` + `ar.json` under `classes.*` |
| EdgeInsetsDirectional | Form / detail / grid padding |
| BorderDirectional | Session card start accent |

---

## Tests

```text
flutter test test/feat18_class_manager_test.dart
→ +8 All tests passed
```

Coverage: Admin gate · Cubit load/create forbidden/softCancel · Stitch citations · Admin regions · Receptionist read-only.

---

## Residuals

- Weekly Schedule EN twin missing in Stitch (AR only) — OK per FSD non-goals  
- Attendee list / Bulk Check-In / capacity booked count are Stitch fixtures until a booking FEAT  
- Full device app screenshot vs Stitch deferred to manual P6 on live Backend  
- Docs milestone plan provisional `[x]` — update on `feature/docs-feat18-portal-audit` if opened  

---

## Manual

Extend / follow `Fithub-documentation/manual-tests/PHASE-FEAT-18-manual-test.md` § Portal P1–P6.
