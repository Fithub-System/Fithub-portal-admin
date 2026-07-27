# FEAT-05 Portal — Staff Invite Verification Audit

**Date:** 2026-07-19  
**Branch:** `feature/portal-feat05-staff-invite`  
**Agent:** Portal Admin  
**Spec:** FEAT-05 US-B / AC-B1–B4, AC-C2  

## Stitch

| Field | Value |
|-------|--------|
| Project | `13435235862240753621` |
| Screen | **Staff Management** (Staff Profile Creator form) |
| Screen id | `dcc070ef2b1e45058b3e042ad70140e3` |
| Access | Stitch MCP HTTP `list_screens` / `get_screen` (`https://stitch.googleapis.com/mcp`) — Cursor catalog omits `user-stitch`; same fallback as Phase 1.2-R |

Implemented UI mirrors Identity & Credentials (name + email), Access Protocol role toggles (Admin / Coach←Trainer / Receptionist←Front Desk), and **INITIALIZE PROFILE** CTA. Emergency Contact + Specialization from Stitch are omitted (not in FEAT-05 invite contract).

## Acceptance

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Invite form → `invite_staff` | PASS (client) | `StaffInviteHttpRemoteDataSource` → `POST /functions/v1/invite-staff` via Dio `ApiProvider` + user JWT + anon `apikey`; body `{email, role, name}` |
| AC-B2 No public Register on Portal login | PASS | `login_page.dart` has no Register CTA; translation guard in `test/staff_invite_feat05_test.dart` |
| AC-B3 Invited staff can sign in | Backend dep | Requires Edge Function deployed + Auth user + `employees` row (Backend FEAT-05) |
| AC-B4 Non-Admin cannot invite | PASS (UI + rely Backend) | `EmployeeProfile.canInviteStaff`; `StaffInviteDeniedView` for non-Admin; Backend 403 |
| AC-C2 No service_role in Flutter | PASS | Only anon key + user bearer; no service_role string in Portal |

## Architecture

- `cleanarch staff_invite -b` scaffold (then implemented to kit naming)
- Per-feature DI: `lib/features/staff_invite/injection_container.dart` → root facade
- Ports: `StaffInviteRepository` / `StaffInviteRemoteDataSource`; Dio HTTP adapter
- i18n EN/AR under `staff_invite.*` (FEAT-03)

## Backend dependency

Portal client targets Edge Function `invite-staff` from Backend branch  
`feature/backend-feat05-register-invite` (not necessarily merged to Backend `dev` yet).

Before live smoke:

1. Apply migration `20260719120000_feat05_athlete_insert_invite_staff.sql`
2. `supabase functions deploy invite-staff`
3. Admin JWT invite → staff login on Portal (Admin/Receptionist) or Coach app (Coach)

## Tests

```bash
flutter test
```

Includes `test/staff_invite_feat05_test.dart` (use case, bloc, Admin gate, Stitch id, AC-B2).

## Verdict

**PASS (client)** — Stitch-cited Invite Staff UI + ports/DI + Admin gate + no public Register.  
**Residual:** live Backend deploy for end-to-end invite → login smoke.
