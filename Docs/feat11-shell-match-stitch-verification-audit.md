# FEAT-11 Portal shell Match Stitch (Install I1) — Verification Audit

**Date:** 2026-07-31  
**Branch:** `feature/portal-feat11-shell-match-stitch`  
**FSD:** `Fithub-documentation/specs/FEAT-11-PORTAL-SHELL-MATCH-STITCH.md`  
**Kickoff:** `Fithub-documentation/kickoff-feat11-portal-shell.md`  
**Manual:** `Fithub-documentation/manual-tests/PHASE-FEAT-11-manual-test.md`  
**Stitch project:** `13435235862240753621`

## Status

**Provisional PASS** — Portal Admin Agent self-check. Awaiting Main BizDev `BizDev Audit: PASS` before merge to `dev`.

**Out of scope (not claimed):** I2 G1 Access Scanner pixel artboard, I3 Gym Settings, I4 Add Member, Classes schedule CRUD, Staff KPI / Profile Creator screens.

## Stitch citations (§3)

| Surface | Stitch id | Evidence |
|---------|-----------|----------|
| Home / Overview | `216e0407184f4c39bd501ed436c1e88b` | `KineticTokens.stitchOccupancyScreenId`; Home → `_DashboardDestination` |
| Members | `9b35dd57f15443e99f7e798f6867acb6` | `MemberManagementScreen.stitchScreenId` |
| Staff | `dcc070ef2b1e45058b3e042ad70140e3` | `_StaffDestination` + `StaffInviteScreen.stitchScreenId` |
| Classes empty EN | `c3b2a1416ebb4f46a71aa108f418e51c` | `ClassesComingSoonPage.stitchScreenIdEn` |
| Classes empty AR | `747d13fbf3b741d09c3a29e18d7b0bd4` | `ClassesComingSoonPage.stitchScreenIdAr` |
| Marketing | `c3207a6938bf40a7872dde7532020ef9` | `MarketingPromotionsScreen.stitchScreenId` |
| Reports empty EN | `ace7bf6e830b4e9f8963cfa5dd07909b` | `ReportsComingSoonPage.stitchScreenIdEn` |
| Reports empty AR | `82188fd0c27a4baa923ead6221e04d7b` | `ReportsComingSoonPage.stitchScreenIdAr` |

**Removed from shell IA:** top-level Scan, top-level Account.

## AC cross-check

| AC | Result | Evidence |
|----|--------|----------|
| AC-A1 Destination count = 6; order Home→…→Reports | PASS | `PortalShellDestinations` indices 0–5; `destinationCount = 6`; rail + `NavigationBar` in `portal_home_shell.dart` |
| AC-A2 No Scan / Account rail destinations | PASS | Rail/bar destinations omit `nav.scan` / `nav.account`; Scan not in `IndexedStack` |
| AC-A3 Home → Admin Overview / dashboard | PASS | Index 0 → `_DashboardDestination` + occupancy gauge |
| AC-A4 Members → FEAT-07-R | PASS | Index 1 → `MemberManagementScreen` |
| AC-A5 Marketing → FEAT-08 | PASS | Index 4 → `MarketingPromotionsScreen` |
| AC-A6 Audit cites Stitch + FEAT-11 §3 | PASS | This doc + code comments on destinations / coming-soon pages |
| AC-B1 Classes cites Stitch EN+AR | PASS | `ClassesComingSoonPage` constants |
| AC-B2 No classes Backend / Drift | PASS | UI-only placeholder; no new RPCs/tables |
| AC-B3 Kinetic `#121212` / `#CCFF00`; no purple | PASS | `KineticComingSoonEmpty` uses `KineticTokens.deepCharcoal` / `electricLime` |
| AC-C1 Reports cites Stitch EN+AR | PASS | `ReportsComingSoonPage` constants |
| AC-C2 No analytics Backend | PASS | UI-only placeholder |
| AC-C3 Optional attendance/revenue line | PASS | `reports.coming_soon.hint` |
| AC-D1 Staff invite under Staff | PASS | `_StaffDestination` hosts `StaffInviteScreen` / `StaffInviteDeniedView` |
| AC-D2 No Staff KPI / Profile Creator extras | PASS | Invite flow only (existing FEAT-05) |
| AC-D3 EN/AR + RTL | PASS | `staff.shell.*`, `staff_invite.*`; `EdgeInsetsDirectional` |
| AC-E1 Language + sign-out via header/avatar | PASS | `_PortalShellHeader` `PopupMenuButton` (locale EN/AR + sign out) |
| AC-E2 `access_scanner` retained; off rail | PASS | Feature folder untouched; not mounted in shell stack |
| AC-E3 Home companion scan may remain; no G1 claim | PASS | Dashboard still shows last-scan message; **not** claiming G1 pixel-complete |
| AC-F1 No new feature folders / cleanarch N/A | PASS | Placeholders extended under `home` (`kinetic_coming_soon_empty.dart`) |
| AC-F2 EasyLocalization EN+AR | PASS | `nav.home|staff|classes|reports`, `classes.*`, `reports.*`, `home.shell.locale_*` |
| AC-F3 No `service_role` in Flutter | PASS | No Backend / secrets changes |
| AC-F4 Branch name | PASS | `feature/portal-feat11-shell-match-stitch` |

## Shell IA change

| Before | After (FEAT-11 I1) |
|--------|---------------------|
| Dashboard · Scan · Members · Marketing · Account (5) | Home · Members · Staff · Classes · Marketing · Reports (6) |
| Staff invite under Account | Staff invite under **Staff** |
| No Classes / Reports | Coming soon empties |
| Sign-out on Account body | Avatar menu (language + sign-out) |

## Tests

- `test/feat11_shell_match_stitch_test.dart` — destination order/count, Stitch ids, Classes/Reports EN+AR smoke
- `test/feat07r_portal_ia_test.dart` — Members index updated to 1
- `test/feat08_billing_test.dart` — Marketing index updated to 4

## Manual test reference

- `Fithub-documentation/manual-tests/PHASE-FEAT-11-manual-test.md`

## Residuals / blockers

1. Live Admin smoke on PHASE-FEAT-11 A1–A5, B1–B6, C1–C2 (human / BizDev).
2. Stitch MCP unavailable in agent session — ids cited from locked FSD §3 (not live pixel pull).
3. Access Scanner remains offline-rail until I2; Home may still show last-scan companion text.
4. Do **not** merge without BizDev Audit PASS.

## Verification Audit (agent)

- [x] Six Stitch-ordered destinations — **Verification Audit:** `PortalShellDestinations` + shell rail/bar.
- [x] Scan / Account removed from rail — **Verification Audit:** destinations list + IndexedStack.
- [x] Staff invite relocated — **Verification Audit:** `_StaffDestination` + Stitch `dcc070ef…`.
- [x] Classes / Reports Coming soon — **Verification Audit:** `ClassesComingSoonPage` / `ReportsComingSoonPage`.
- [x] Avatar menu language + sign-out — **Verification Audit:** `_PortalShellHeader`.
- [x] EN/AR i18n — **Verification Audit:** `en.json` / `ar.json` keys.
- [x] Tests — **Verification Audit:** `feat11_shell_match_stitch_test.dart` + updated FEAT-07-R / FEAT-08 index tests.
