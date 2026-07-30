# FEAT-08 Billing — Portal Verification Audit

**Date:** 2026-07-29  
**Branch:** `feature/portal-feat08-billing`  
**FSD:** `Fithub-documentation/specs/FEAT-08-BILLING.md` (US-B + §3)  
**Kickoff:** `Fithub-documentation/kickoff-feat08-billing.md`  
**Backend contract:** `Fithub-backend/docs/feat08-billing-backend.md`  
**Manual test:** `Fithub-documentation/manual-tests/PHASE-FEAT-08-manual-test.md` (§B Portal)

## Status

**Provisional PASS** — Portal Agent Verification Audit. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

## Stitch

- Screen: Marketing & Promotions `c3207a6938bf40a7872dde7532020ef9`
- Cited on `MarketingPromotionsScreen.stitchScreenId`
- Stitch MCP unavailable in this agent session catalog — Kinetic tokens used for list UI
- **Design Gap:** Full Marketing/Promotions campaigns UI not in v1 scope; shell destination hosts **Billing** section only (FSD §3)

## AC cross-check (Portal scope)

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Admin UPDATE paid/waived/failed | PASS (client) | `BillingSupabaseRemoteDataSource.updateChargeStatus` → PATCH `membership_charges.status`; CTAs on `MarketingPromotionsScreen` |
| AC-B2 Receptionist SELECT only | PASS (UI) | `EmployeeProfile.canManageBilling`; write CTAs + freeze gated; read-only hint |
| AC-B3 EN/AR | PASS | `billing.*` + `nav.marketing` in `en.json` / `ar.json` |
| AC-C3 apply_billing_freeze | PASS (optional) | Admin CTA → RPC `apply_billing_freeze(p_tenant_id)` |
| AC-E1 No service_role | PASS | User-scoped `supabase_flutter` client only |
| Nav Stitch-aligned | PASS | Marketing shell destination (index 3); no freehand conflicting root |

## Tests

- `flutter test test/feat08_billing_test.dart` — Admin gate, cubit load/mark/freeze, Stitch id, shell indices
- Full suite: `flutter test`

## Residuals

1. Live Admin smoke per PHASE-FEAT-08 §B (requires Backend FEAT-08 migration applied).
2. Member Management Freeze stubs (FEAT-07-R) left untouched — not on `origin/dev`.
3. Promotions/campaigns content beyond Billing deferred (Design Gap above).

## Links

| Resource | Path |
|----------|------|
| Manual test §B | `Fithub-documentation/manual-tests/PHASE-FEAT-08-manual-test.md` |
| Backend PR | https://github.com/Fithub-System/Fithub-backend/pull/12 |
