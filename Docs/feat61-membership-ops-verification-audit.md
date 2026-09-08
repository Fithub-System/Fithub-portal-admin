# FEAT-61 — Portal Membership Renew / Freeze + plan tag — Verification Audit

**Date:** 2026-09-08  
**Branch:** `feature/portal-feat61-membership-ops`  
**Base:** `origin/dev`  
**FSD:** `Fithub-documentation/specs/FEAT-61-MEMBERSHIP-RENEW-FREEZE.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat61-membership-ops.md`  
**GitHub:** [#42](https://github.com/Fithub-System/Fithub-portal-admin/issues/42)  
**Backend contract:** `Fithub-backend/docs/feat61-membership-ops-backend.md` (PR [#78](https://github.com/Fithub-System/Fithub-backend/pull/78))  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-61-manual-test.md`

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev
`BizDev Audit: PASS` before merge to `dev`. **Do not merge.**

## Stitch / Visual Spec

- Members hub EN `9b35dd57f15443e99f7e798f6867acb6` / AR `60b6a0e1f7fb4419b1b0e774ec8bdb32`
  (`MemberManagementScreen`)
- Gym Settings G2 EN/AR unchanged; Freeze policy **nested** (no dedicated Stitch)
- Visual Spec Card: `Docs/feat61-visual-spec-freeze-policy.md`

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 exact plan chip | PASS | `membersPlanChipLabel` — live `membershipPlanName`; no Elite/Standard/Basic keyword heuristic |
| AC-B2 Renew Admin confirm → RPC → refresh | PASS | `renew_membership` via `MembershipsCubit.renewMembership`; dialog; `refreshFromCloud` |
| AC-B3 Freeze/Unfreeze + days default/cap | PASS | `freeze_membership` / `unfreeze_membership`; dialog days from policy; max validated |
| AC-B4 Receptionist plan names; Renew Admin-only; Freeze staff | PASS | `canRenewMembership` Admin; `canFreezeMembership` Admin+Receptionist |
| AC-B5 Members Stitch cite; EN/AR | PASS | Screen ids + `members.*` / dialog keys EN+AR |
| AC-C1 Settings general + per-plan | PASS | `FreezePolicySettingsSection` under `GymSkuSettingsScreen` |
| AC-C2 validation max≥1, freeze≤max | PASS | UI + `UpsertFreezePolicyUseCase` / cubit |
| AC-C3 Admin-only + Visual Spec Card | PASS | `canManageSkuSettings` / section `canWrite`; Visual Spec Card filed |
| AC-E2 branch from origin/dev | PASS | `feature/portal-feat61-membership-ops` |
| No service_role | PASS | User-JWT Supabase client RPCs only |

## RPCs used (authenticated)

- `upsert_freeze_policy` / `list_freeze_policies`
- `freeze_membership` / `unfreeze_membership` / `renew_membership`

## Tests

```text
flutter test test/feat61_membership_ops_test.dart \
  test/feat07_memberships_test.dart \
  test/feat07r_portal_ia_test.dart \
  test/feat16_vf2_members_fidelity_test.dart
```

## Residuals

1. Live Admin/Receptionist smoke vs Backend `dev` (PHASE-FEAT-61 P1–P9) — not claimed here.
2. Athlete self-freeze (US-D) — Athlete track.
3. Yearly freeze pool / Receptionist Renew — out of MVP.
4. Do **not** claim BizDev PASS; do **not** merge without BizDev.
