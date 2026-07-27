# FEAT-07 Memberships — Portal Verification Audit

**Date:** 2026-07-27  
**Branch:** `feature/portal-feat07-memberships`  
**FSD:** `Fithub-documentation/specs/FEAT-07-MEMBERSHIPS.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat07-memberships.md`  
**Backend contract:** `Fithub-backend/docs/feat07-memberships-backend.md`  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-07-manual-test.md`

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

## Stitch

- Stitch MCP **unavailable** in this agent session catalog.
- UI follows Kinetic Monolith tokens + companion Admin Overview  
  `216e0407184f4c39bd501ed436c1e88b` (same residual rule as FEAT-01 Access Scanner).
- Cited on `MembershipsScreen.stitchCompanionScreenId`.

## AC cross-check (Portal scope)

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Create plan | PASS (client) | `MembershipsSupabaseRemoteDataSource.createPlan` → `membership_plans` insert with tenant_id |
| AC-A2 List / soft-deactivate | PASS (client) | list + `is_active=false` update; RLS tenant isolation on Backend |
| AC-A3 Receptionist read / Admin write | PASS (UI) | `EmployeeProfile.canManageMemberships`; write CTAs gated; Receptionist read-only hint |
| AC-A4 EN/AR | PASS | `memberships.*` + `nav.memberships` in `en.json` / `ar.json` |
| AC-B1–B2 Assign RPC | PASS (client) | `assign_membership` RPC; Backend auto-expires previous active |
| AC-B4 Non-Admin cannot assign | PASS (UI + Backend) | UI gate + Backend Admin-only RPC |
| AC-D / Marketplace UI | PASS (N/A) | No Marketplace UI shipped |
| AC-E1 No service_role | PASS | User-scoped `supabase_flutter` client only |
| Roster cache status | PASS | Drift `LocalMembers` + schema v2; roster sync joins active memberships |
| Scanner badge | PASS | `ScanSuccessBanner` uses cached status; unknown → Active fallback |

## Tests

- `flutter test` — includes `test/feat07_memberships_test.dart`

## Residuals

1. Live Admin smoke: create plan → assign → roster sync → scanner badge (see PHASE-FEAT-07).
2. Dedicated Stitch Membership screen when MCP available — replace companion citation.
3. Athlete profile status is **Athlete track** (out of Portal scope).
