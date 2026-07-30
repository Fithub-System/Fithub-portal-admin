# FEAT-07-R Portal Memberships IA — Verification Audit

**Date:** 2026-07-29  
**Branch:** `feature/portal-feat07r-memberships-ia`  
**FSD:** `Fithub-documentation/specs/FEAT-07-R-PORTAL-MEMBERSHIPS-IA.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat07r-portal-ia.md`  
**Parent:** FEAT-07 Portal memberships (functionality preserved; IA only)

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

## Stitch

- Stitch MCP **unavailable** in this agent session catalog.
- Member Management screen cites Stitch id `9b35dd57f15443e99f7e798f6867acb6` on `MemberManagementScreen.stitchScreenId`.
- RTL/LTR twins (`90b435dba33c4af9b80caa9eeb67d801`, `60b6a0e1f7fb4419b1b0e774ec8bdb32`) referenced in FSD for copy audit only.

## AC cross-check (Portal scope)

| AC | Result | Evidence |
|----|--------|----------|
| AC-R1 No Memberships nav tab | PASS | `PortalHomeShell` rail + bottom nav use `nav.members`; no `nav.memberships` |
| AC-R2 Members nav destination | PASS | Index `PortalShellDestinations.members` (2) → `MemberManagementScreen` |
| AC-R3 Stitch screen citation | PASS | `MemberManagementScreen.stitchScreenId` = `9b35dd57f15443e99f7e798f6867acb6` |
| AC-R4 EN/AR + RTL | PASS | `nav.members`, `members.*` in `en.json` / `ar.json`; directional padding |
| AC-R5 Plan CRUD preserved | PASS | `MembershipsPlansPanel` reuses `MembershipsCubit` + same remote data source |
| AC-R6 Assign RPC preserved | PASS | `assign_membership` via existing cubit; row + Plans tab assign |
| AC-R7 Receptionist read-only | PASS | `canWrite` gates create/deactivate/assign; read-only hint on Plans tab |
| AC-R8 Drift roster cache unchanged | PASS | No schema change; `listCachedMembers` reads existing `LocalMembers` fields |
| AC-R9 Roster Plan Type column | PASS | `MemberRosterTable` shows `membershipPlanName` from cache |
| AC-R10 Freeze / Renew labels | PASS (stub) | Disabled row actions; FEAT-08 billing/freeze not wired |
| AC-R11 Plans nested under Members | PASS | TabBar: Roster + Plans; no root nav tab for plans |

## Shell IA change

| Before (FEAT-07) | After (FEAT-07-R) |
|------------------|-------------------|
| Nav index 2: Memberships → `MembershipsScreen` | Nav index 2: Members → `MemberManagementScreen` |
| Standalone plans page | Plans embedded in Members **Plans** tab |

## Tests

- `flutter test` — includes `test/feat07r_portal_ia_test.dart` (shell indices + Member Management smoke)
- `test/feat07_memberships_test.dart` updated for Stitch citation on `MemberManagementScreen`

## Manual test reference

- `Fithub-documentation/manual-tests/PHASE-FEAT-07-manual-test.md` — Portal steps should use **Members** nav (not Memberships). File lives in documentation repo; not duplicated in portal `Docs/`.

## Residuals

1. Live Admin smoke: Members → Plans → create/assign; roster Plan Type after sync (PHASE-FEAT-07).
2. **Freeze / Renew** actions disabled until FEAT-08 freeze/billing ships.
3. Stitch MCP pixel parity pass when MCP available.

## Verification Audit (agent)

- [x] Removed freehand Memberships shell destination — **Verification Audit:** rail + `NavigationBar` destinations updated; `PortalShellDestinations.members = 2`.
- [x] Added Members → MemberManagementScreen with Stitch id — **Verification Audit:** `stitchScreenId` constant + widget smoke test.
- [x] Embedded plans CRUD + assign — **Verification Audit:** `MembershipsPlansPanel` under Plans tab; same cubit/repo/RPC.
- [x] Roster table Plan Type + Admin assign + Freeze/Renew stubs — **Verification Audit:** `MemberRosterTable` + disabled freeze/renew.
- [x] EN/AR i18n — **Verification Audit:** `nav.members`, `members.*` keys added both locales.
- [x] Tests — **Verification Audit:** `feat07r_portal_ia_test.dart` shell indices + smoke.
