# FEAT-62 Portal — Member Invite (US-B) Verification Audit

**Date:** 2026-09-08  
**Branch:** `feature/portal-feat62-invite-otp`  
**Agent:** Portal Admin  
**FSD:** `Fithub-documentation/specs/FEAT-62-INVITE-OTP.md` (US-B)  
**Kickoff:** `Fithub-documentation/kickoff-feat62-invite-otp.md`  
**Issue:** [#46](https://github.com/Fithub-System/Fithub-portal-admin/issues/46)  
**Backend contract:** `Fithub-backend/docs/feat62-member-invite-otp-backend.md`  
**Backend PR:** [#80](https://github.com/Fithub-System/Fithub-backend/pull/80) → `dev` (BizDev PASS)  
**Manual:** `Fithub-documentation/manual-tests/PHASE-FEAT-62-manual-test.md`  
**Visual Spec Card:** `Docs/feat62-visual-spec-add-member-invite.md`

## Status

**Provisional PASS (client)** — Portal Agent Verification Audit.  
**Do not merge without BizDev PASS.** Never claim BizDev PASS from this audit.

## Stitch / Visual Spec

| Field | Value |
|-------|--------|
| EN | `cd59a129a24449478a5249ccb41635fb` (`AddMemberScreen.stitchScreenIdEn`) |
| AR | `89fe5d7afb8d4d4384d7e6498bcdd065` |
| Visual Spec Card | `Docs/feat62-visual-spec-add-member-invite.md` |
| MCP | `user-stitch` unavailable — reused FEAT-13 locked G4 citations |

## Architecture

- Edge: `POST /functions/v1/invite-member` via Dio `ApiProvider` + Admin JWT + anon `apikey`
  (`MemberInviteHttpRemoteDataSource`, `AppEndpoints.inviteMember`)
- Body: `{ email|username, display_name?, plan_id? }` — no OTP returned to client in prod
- Link tab: unchanged FEAT-13 RPCs (`find_athlete_for_enroll` / `enroll_gym_member`)
- No client `service_role`
- DI: `InviteMemberUseCase` + `CloudMutationGuard` (FEAT-26 offline deny)

## AC cross-check (US-B)

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Invite tab operable → Edge | PASS (client) | Live form; `InviteMemberUseCase` → repo → HTTP Edge |
| AC-B2 Link tab unchanged | PASS | `_LinkExistingTab` Flow A preserved |
| AC-B3 Admin-only; EN/AR; Stitch cite | PASS | `canEnrollMembers` gates Add Member CTA; `add_member.*` EN/AR; Visual Spec + screen constants |
| AC-B4 Honest errors | PASS | username not found / invite email failed / forbidden / offline keys |

## Guest Insights (optional)

**Deferred (honest fixture).** `member_invite_counts` not bound into Overview Home —
would require extending FEAT-60 metrics plumbing; Spec allows leaving fixture.

## Tests

```bash
flutter test test/feat62_invite_otp_test.dart test/feat13_add_member_test.dart
```

## Residuals

1. Live Admin smoke vs deployed Edge `invite-member` (PHASE-FEAT-62 P2–P4).
2. Guest Insights optional bind to `member_invite_counts`.
3. Athlete US-C OTP accept (out of Portal scope).
4. BizDev PASS before merge to `dev`.
