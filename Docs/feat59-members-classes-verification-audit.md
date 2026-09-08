# FEAT-59 — Members live + Classes day-cell IA — Verification Audit

**Date:** 2026-09-08  
**Branch:** `feature/portal-feat59-members-classes`  
**Base:** `origin/dev`  
**FSD:** `Fithub-documentation/specs/FEAT-59-PORTAL-MEMBERS-LIVE-AND-CLASSES-IA.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat59-portal-members-classes.md`  
**GitHub:** [#36](https://github.com/Fithub-System/Fithub-portal-admin/issues/36)  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-59-manual-test.md`

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev
`BizDev Audit: PASS` before merge to `dev`. **Do not merge.**

## Stitch

- Members hub EN `9b35dd57f15443e99f7e798f6867acb6` (cited on `MemberManagementScreen`)
- Add Member EN `cd59a129a24449478a5249ccb41635fb` / AR `89fe5d7afb8d4d4384d7e6498bcdd065`
- Classes calendar visual language per FEAT-18 (`40cc7e5d…`); empty-slot IA unlocked
- Cursor `user-stitch` MCP unavailable this session — citations + existing Visual Spec Cards used
- Visual Spec Card (empty-slot): `Docs/feat59-visual-spec-empty-slot.md`

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 refresh on open | PASS | `portal_home_shell` Members cubit `..refreshFromCloud()` |
| AC-A2 no fixture mask | PASS | `MemberManagementScreen` uses live `state.members`; empty → `_EmptyRosterChrome` |
| AC-A3 loading/error + retry EN/AR | PASS | Failure banner + empty Retry → `refreshFromCloud`; i18n updated |
| AC-A4 receptionist / Admin gates | PASS | Unchanged `canWrite` / `canEnroll` |
| AC-B1 center Add Member | PASS | `Align(topCenter)` + `ConstrainedBox(maxWidth: formMaxWidth=720)` |
| AC-B2 Stitch cite, no IA invent | PASS | Screen ids unchanged; centering only |
| AC-C1 all empty Admin cells | PASS | Wed-09-only removed; hover/focus shows Schedule New chrome |
| AC-C2 reuse `onSchedule` | PASS | `onScheduleSlot` → `beginDraftSlot` unchanged |
| AC-C3 coach/RLS unchanged | PASS | No Backend / role gate changes |
| AC-D1 branch from `origin/dev` | PASS | `feature/portal-feat59-members-classes` |
| AC-D2 no `service_role` + tests | PASS | User-scoped client only; `test/feat59_members_classes_test.dart` |

## Out of scope (confirmed untouched)

- Renew / Freeze enable (FEAT-61)
- Plan tag remap (FEAT-61)
- Invite / OTP enroll (FEAT-62)
- Home KPI bind (FEAT-60)

## Tests

- `test/feat59_members_classes_test.dart` — **8 passed**
- Related regression suite (feat59 + feat16 VF2 + feat13 + feat18) — **28 passed**

```text
flutter test \
  test/feat59_members_classes_test.dart \
  test/feat16_vf2_members_fidelity_test.dart \
  test/feat13_add_member_test.dart \
  test/feat18_class_manager_test.dart
```

## Residuals

1. Live Admin smoke vs Backend `dev` roster + class upsert (PHASE-FEAT-59).
2. Dedicated Stitch pixel re-fetch when MCP available.
3. `MembersStatsBento.activeSessions` still uses fixture constant (pre-existing; FEAT-60).
