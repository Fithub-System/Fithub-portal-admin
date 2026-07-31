# FEAT-13 Add Member — Portal Verification Audit

**Date:** 2026-07-31  
**Branch:** `feature/portal-feat13-add-member`  
**FSD:** `Fithub-documentation/specs/FEAT-13-ADD-MEMBER.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat13-add-member.md`  
**Backend contract:** `Fithub-backend/docs/feat13-enroll-member-backend.md`  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-13-manual-test.md`

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev
`BizDev Audit: PASS` before merge to `dev`.

## Scaffold

- New feature via `cleanarch add_member -b` (Bloc).
- Feature DI: `lib/features/add_member/inject_add_member.dart` →
  `registerAddMemberDependencies` wired from root `InjectionContainer.init()`.

## Stitch

- Stitch MCP **unavailable** in this agent session catalog.
- Cited locked ids on `AddMemberScreen` + `KineticTokens`:
  - EN `cd59a129a24449478a5249ccb41635fb`
  - AR `89fe5d7afb8d4d4384d7e6498bcdd065`
- Entry: Members hub CTA **Add New Member** only
  (`MemberManagementScreen`, parent Stitch `9b35dd57f15443e99f7e798f6867acb6`).
- Kinetic Monolith tokens (charcoal / electric lime).

## AC cross-check (Portal scope)

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Stitch G4 + Members CTA | PASS | `AddMemberScreen.stitchScreenIdEn/Ar`; Admin CTA `add_member.cta.add_new` |
| AC-B2 find → enroll → optional assign | PASS | `find_athlete_for_enroll` then `enroll_gym_member`; optional `assign_membership` |
| AC-B3 Validation / success toasts; EN/AR | PASS | `add_member.*` in `en.json` / `ar.json`; snackbars via `StitchAuthSnackbar` |
| AC-B4 Receptionist no enroll | PASS | `EmployeeProfile.canEnrollMembers`; CTA gated `canEnroll` |
| AC-B5 Invite stub | PASS | Invite tab + disabled “Send invite later” (Flow A unblocked) |
| AC-C1 No service_role | PASS | User-scoped `supabase_flutter` client only |
| AC-A4 No raw gym_members INSERT | PASS | RPC adapters only in `AddMemberSupabaseRemoteDataSource` |

## Out of scope

- FEAT-12 Access Scanner / Check-in Gate
- FEAT-10 Settings
- Backend RPC migration (separate Backend PR)

## Tests

- `flutter test test/feat13_add_member_test.dart`
- Full suite: `flutter test`

## Residuals

1. Live Admin smoke against Backend `dev` RPCs (PHASE-FEAT-13).
2. Dedicated Stitch pixel pass when MCP available.
