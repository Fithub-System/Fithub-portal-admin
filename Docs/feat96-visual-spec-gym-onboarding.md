# Visual Spec Card — FEAT-96 Gym Self-Service Onboarding

## Meta

| Field | Value |
|-------|-------|
| FEAT | FEAT-96 |
| Stitch project | `13435235862240753621` |
| Platform | DESKTOP |
| formMaxWidth | `720` (FEAT-59) |
| Author | Portal Admin Agent |

## Screens

| Surface | EN | AR |
|---------|----|----|
| Register | `4ca7b76eff8742ffb57fd394709c4a63` | `69cda5c26fb44c6680f6eafb41b5743a` |
| Step 1 Brand | `89e695b4c4bc4a8d8319bcf9afcc8ac5` | `f8dc732ab0174a0e8a988e4921260b01` |
| Step 2 Branch | `9dfae0b2f71f40299c24671b43fe4813` | `f2beab5848624f41a3a0495d3fa65e35` |
| Step 3 Staff | `7ddcc18394434ed78dc229e2adb6dc98` | `fe2e9a3c8f7241238429038e9a72ea10` |
| Step 4 Plans | `f3635eacecce40c385c0b335c371a0bb` | `3f4a86b5c8e8464ea47b9ee31f1cc273` |
| Step 5 Publish | `a5827af544e540b7a7890da089327b2a` | `940b75f4938542f6ab39e60561899028` |
| Settings Profile | `28a6e5e325164b70a9a139f4599832c4` | `fc6cb55221c94031a4b8bf9c1ca42be9` |

Inventory PNGs: `Fithub-documentation/specs/feat96-assets/`.

## Design gaps (must obey)

1. Settings artboard rail — **ignore**. Profile is a Settings hub module, not a 7th rail.
2. Register “Must be facility domain” — **ignore**. Any email in Sandbox.
3. Stitch chrome junk (`FITBIT_JUBING_JACKS`) is not copy.

## Regions implemented

| # | Region | Flutter |
|---|--------|---------|
| 1 | Login Register CTA | `login-cta-register` |
| 2 | Founder form (trading, email, password, confirm) | `GymRegisterPage` |
| 3 | Check-email interstitial | `GymCheckEmailPage` |
| 4 | Stepper Brand · Branches · Staff · Plans · Publish | `_Stepper` |
| 5 | Kinetic card ≤ 720 | `formMaxWidth` |
| 6 | Lime primary + Finish later | `_LimeButton` / `onboarding.finish_later` |
| 7 | Amenity FilterChips | parking/ac/ladies_only/spa/sauna/crossfit/locker_rooms/nutrition_bar |
| 8 | Score circle + 3 checks | `_ReviewStep` |
| 9 | Settings → Gym Profile module | `_SettingsModule.profile` |

## Tokens

`#121212` deep charcoal · `#CCFF00` electric lime · Lexend EN / Cairo AR.
