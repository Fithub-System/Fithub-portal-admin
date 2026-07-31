# FEAT-10 Portal Gym Settings (Install I3) — Verification Audit

**Date:** 2026-07-31  
**Branch:** `feature/portal-feat10-sku-settings`  
**FSD:** `Fithub-documentation/specs/FEAT-10-MARKETPLACE-BOUNDARY.md` (US-D / §3.2 / §4 RPC)  
**Kickoff:** `Fithub-documentation/kickoff-feat10-portal-settings.md`  
**Manual:** `Fithub-documentation/manual-tests/PHASE-FEAT-10-PORTAL-manual-test.md`  
**Backend contract:** `Fithub-backend/docs/feat10-marketplace-boundary-backend.md`  
**Stitch project:** `13435235862240753621`

## Status

**Provisional PASS** — Portal Admin Agent self-check. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

**Out of scope (not claimed):** FEAT-13 Add Member, Coach Job Marketplace, raw PostgREST UPDATE of SKU columns.

## Stitch citations (§3.2)

| Surface | Stitch id | Evidence |
|---------|-----------|----------|
| Gym Settings / SKU & Marketplace (EN) | `6cb93d6100314ce8a5d9c1af92c97723` | `KineticTokens.stitchGymSettingsScreenId`; `GymSkuSettingsScreen.stitchScreenId` |
| Gym Settings AR | `9541b6e764dd436daa91336b0ce2263b` | `KineticTokens.stitchGymSettingsScreenIdAr`; `GymSkuSettingsScreen.stitchScreenIdAr` |

**Entry:** Avatar menu (`home.shell.gym_settings`) **and** Reports nest (`ReportsShellPage`) — **not** a 7th rail tab (AC-D4).

## AC cross-check (Portal / US-D)

| AC | Result | Evidence |
|----|--------|----------|
| AC-D1 Stitch G2 EN+AR cited | PASS | Tokens + screen constants + this audit |
| AC-D2 RPC only `set_gym_sku_settings` | PASS | `GymSkuSettingsSupabaseRemoteDataSource.setGymSkuSettings` → `client.rpc('set_gym_sku_settings', …)`; no PostgREST UPDATE of `sku_mode` / `marketplace_opt_in` |
| AC-D3 EN/AR + RTL | PASS | `gym_settings.*`, `home.shell.gym_settings`, `reports.settings_nest.*` in `en.json` / `ar.json`; EdgeInsetsDirectional / TextAlign.start |
| AC-D4 No new root nav destination | PASS | `PortalShellDestinations.destinationCount = 6`; settings via focus overlay |
| Private Cloud forces opt-in off | PASS | UI disables toggle; `SetGymSkuSettingsUseCase` forces `false`; Bloc clears draft on mode change |
| Admin mutate / Receptionist read-only | PASS | `EmployeeProfile.canManageSkuSettings`; `GymSkuSettingsScreen(canWrite:)` hides Save / disables radios |
| AC-E1 No service_role | PASS | User-scoped `supabase_flutter` client only |
| cleanarch + DI | PASS | `cleanarch gym_sku_settings -b`; `registerGymSkuSettingsDependencies` wired from root `InjectionContainer` |

## Install wiring

| Surface | Behavior |
|---------|----------|
| Avatar menu | Gym Settings → `_settingsFocus` overlay |
| Reports nest | `ReportsShellPage` tile → same overlay |
| Rail | Unchanged six destinations (Home…Reports) |

## Tests

```bash
flutter test test/feat10_portal_sku_settings_test.dart test/feat11_shell_match_stitch_test.dart
```

- `test/feat10_portal_sku_settings_test.dart` — Admin gate, Stitch ids, six destinations, Private Cloud force-off use case, Bloc load/save/forbidden, Reports nest EN/AR
- `test/feat11_shell_match_stitch_test.dart` — rail IA regression

## Manual test reference

- `Fithub-documentation/manual-tests/PHASE-FEAT-10-PORTAL-manual-test.md`
- Provider guide §I3

## Residuals / blockers

1. Live Admin / Receptionist smoke per PHASE-FEAT-10-PORTAL (human / BizDev).
2. Stitch MCP unavailable in agent session — ids cited from locked FSD §3.2 / brief pack.
3. Do **not** merge without BizDev Audit PASS. Do **not** include FEAT-13 Add Member in this PR.

## Verification Audit (agent)

- [x] Entry via avatar / Reports nest (not rail) — **Verification Audit:** `_settingsFocus` + `ReportsShellPage`.
- [x] Stitch G2 EN+AR cited — **Verification Audit:** `KineticTokens` + screen constants.
- [x] RPC only — **Verification Audit:** `set_gym_sku_settings` in remote DS.
- [x] Private Cloud disables marketplace — **Verification Audit:** use case + Bloc + Switch `onChanged: null`.
- [x] Admin-only mutate — **Verification Audit:** `canManageSkuSettings` + `canWrite`.
- [x] EN/AR i18n — **Verification Audit:** `en.json` / `ar.json` `gym_settings.*`.
- [x] cleanarch `-b` + DI — **Verification Audit:** `lib/features/gym_sku_settings/` + root register.
- [x] Tests — **Verification Audit:** `feat10_portal_sku_settings_test.dart`.
