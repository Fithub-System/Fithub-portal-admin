# FEAT-96 Onboarding UX bugfixes — Verification Audit

**Date:** 2026-09-20  
**Branch:** `feature/portal-feat96-profile-edit`  
**PR:** [#70](https://github.com/Fithub-System/Fithub-portal-admin/pull/70)  
**FSD:** `Fithub-documentation/specs/FEAT-96-GYM-SELF-SERVICE-ONBOARDING.md`  
**Visual spec:** `Docs/feat96-visual-spec-gym-onboarding.md`  
**Backend contract:** `Fithub-backend/docs/feat96-gym-onboarding-backend.md`  
**Stitch project:** `13435235862240753621`

## Status

**Provisional PASS** — Portal Admin Agent self-check. Awaiting Main BizDev
`BizDev Audit: PASS` on each item below. **Do not merge** until BizDev stamps PASS.

## Items for BizDev audit

### 1. Gym Profile stepper is tappable + translated titles

- [x] **Verification Audit:** Settings → Gym Profile stepper (Brand · Branches · Staff · Plans · Publish) is an `InkWell` per step (`gym-profile-step-0`…`4`). Titles use `onboarding.steps.*` in `en.json` / `ar.json` (no hardcoded English). EN widget test + AR titles test in `test/feat96_gym_onboarding_test.dart`.

### 2. Register & Onboarding pre-filled editable data

- [x] **Verification Audit:** Register trading/email start filled with translated sample values (`onboarding.register.trading_hint` / `email_hint`) so the founder can edit. Wizard Brand fields bind `gym_onboarding_snapshot` (`name`, `trading_name`, contact) into `_BoundField` controllers after `load()`. Test: `register form is pre-filled so founder can edit`; Gym Profile test expects `Pulse Maadi`.

### 3. Plans step allows more than one plan

- [x] **Verification Audit:** Plans step lists `savedPlans` from FEAT-07 `ListMembershipPlansUseCase` (`activeOnly: true`). **Add another plan** calls `savePlan()` and stays on step 3 with a cleared draft. **Continue to publish** uses `continueToReview()` (saves draft if present, or advances when ≥1 saved plan). RPC unchanged (`createPlan` / FEAT-07). Cubit test: `savePlan can add more than one plan and stay on Plans`.

### 4. Branches facilities are translated

- [x] **Verification Audit:** Amenity `FilterChip` labels use `onboarding.step2.amenities.{tag}` plus heading `onboarding.step2.facilities`. Wire tags (`parking`, `ac`, …) are unchanged for `set_branch_facilities`. Widget test: `Branches facilities chips use translated labels`.

## Tests

```bash
flutter test test/feat96_gym_onboarding_test.dart
```

## Residuals

1. Live Admin smoke on Settings → Gym Profile (human / BizDev).
2. Stitch MCP `get_screen` failed in this session (auth). Tokens taken from locked visual spec + existing EN/AR copy.
3. Do **not** merge without BizDev Audit PASS. Do **not** claim the phase is done.
