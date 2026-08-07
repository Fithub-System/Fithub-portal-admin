# FEAT-23 — Portal Marketing Verification Audit

**Branch:** `feature/portal-feat23-marketing`  
**FSD:** `Fithub-documentation/specs/FEAT-23-PORTAL-MARKETING.md` (**LOCKED**)  
**Backend:** BizDev PASS — PR [#28](https://github.com/Fithub-System/Fithub-backend/pull/28) · contract `Fithub-backend/docs/feat23-marketing-backend.md`  
**Issue:** https://github.com/Fithub-System/Fithub-backend/issues/27  
**Date:** 2026-08-07  
**Agent:** Portal Admin Agent

---

## Scaffold

| Item | Value |
|------|-------|
| cleanarch | `cleanarch marketing -b` |
| DI | `registerMarketingDependencies` → root `InjectionContainer` |
| SELECT | `marketing_campaigns` / `promo_codes` via RLS |
| Writes | `rpc('upsert_marketing_campaign')` / `rpc('upsert_promo_code')` only — no table INSERT |
| service_role | None |
| supabase_flutter in presentation | None (data source only) |
| FEAT-08 billing | Intact — `BillingChargesSection` secondary on Marketing rail |

---

## Acceptance Criteria

### US-A — Staff views Marketing Growth Engine

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Tenant-scoped list via RLS | PASS (client) | SELECT campaigns/promos; RLS stamps tenant |
| AC-A2 Cites Stitch EN+AR | PASS | Spec Card + `MarketingScreen.stitchScreenIdEn/Ar` |
| AC-A3 Primary chrome Growth Engine | PASS | Flash Sale / ACTIVE PROMOS / analytics — not charges-only |
| AC-A4 No freehand rail / nav | PASS | `PortalShellDestinations` unchanged (6 destinations) |
| AC-A5 FEAT-08 charges secondary | PASS | `BillingChargesSection` under Billing / Charges |

### US-B — Admin deploys / edits campaign

| AC | Result | Evidence |
|----|--------|----------|
| AC-B1 Admin write via RPC | PASS (client) | `MarketingSupabaseRemoteDataSource.upsertCampaign` |
| AC-B2 Receptionist SELECT only | PASS (client) | `canManageMarketing` / Deploy disabled |
| AC-B3 Inline Flash Sale form | PASS | `FlashSaleCampaignForm` |
| AC-B4 Push send residual | PASS | `push_enabled` stored only |
| AC-B5 Soft-end | PASS | End campaign → `status=ended` via RPC |

### US-C — Admin manages promo codes

| AC | Result | Evidence |
|----|--------|----------|
| AC-C1 Admin write via RPC | PASS (client) | `upsert_promo_code` |
| AC-C2 Unique code / XOR discount | PASS (client) | Bloc validation + Backend CHECK |
| AC-C3–C4 Status chrome | PASS | active / expired / inactive badges |
| AC-C5 Redeem engine OOS | PASS | `redeemed_count` display only |

### US-D — Analytics fixtures

| AC | Result | Evidence |
|----|--------|----------|
| AC-D1 Reach / CTR / Revenue / Conversion | PASS | `MarketingStitchFixtures` |
| AC-D2 Asset Library fixture | PASS | `AssetLibraryCard` |

---

## Visual Fidelity §E2

| Item | Result |
|------|--------|
| Visual Spec Card | `Docs/feat23-visual-spec-c3207a69.md` |
| Region checklist | `Docs/feat23-marketing-region-checklist.md` |
| Stitch MCP fetch | HTTP `get_screen` (EN+AR) → `Docs/feat23-assets/` |
| Side-by-side | Stitch PNGs + widget-test region evidence |

---

## i18n / RTL

| Item | Result |
|------|--------|
| EN/AR keys | `assets/translations/en.json` + `ar.json` under `marketing.*` |
| EdgeInsetsDirectional | Screen / form / promo / billing padding |
| Border start accent | Flash Sale lime start border |

---

## Tests

```text
flutter test test/feat23_marketing_test.dart test/feat08_billing_test.dart --concurrency=1
→ +16 All tests passed (feat23 +7 · feat08 +9 regression)
```

Coverage: Admin gate · Bloc load / forbidden deploy / promo XOR · Stitch citations · Admin Growth Engine regions + Billing secondary title · Receptionist disable Deploy.

---

## Residuals

- Push send / FCM delivery  
- Promo redeem at membership checkout  
- Live analytics warehouse (fixtures OK)  
- Asset Library depth / media upload  
- Full device app screenshot for BizDev P7 (widget-test regions shipped)

---

## Links

- Kickoff: `Fithub-documentation/kickoff-feat23-marketing.md`  
- Manual: `Fithub-documentation/manual-tests/PHASE-FEAT-23-manual-test.md`  
- Backend contract: `Fithub-backend/docs/feat23-marketing-backend.md`  
