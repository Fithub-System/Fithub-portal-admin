# Visual Spec Card — FEAT-96 / FEAT-97 pixel lock

## Meta

| Field | Value |
|-------|-------|
| Date | 2026-09-20 |
| Stitch project | `13435235862240753621` |
| Brand Lock | `assets/12737976743993098844` |
| Device | DESKTOP |
| formMaxWidth | `720` |
| Tokens | canvas `#121212` · card `#1C1B1B` · lime `#CCFF00` · coral `#FF3B30` |

Fetched via Stitch HTTP MCP `get_screen` (gcloud Bearer). PNGs: `Fithub-documentation/specs/feat96-assets/` and `feat97-assets/`.

## FEAT-96 screens

| Surface | EN | AR | Flutter |
|---------|----|----|---------|
| Register | `4ca7b76eff8742ffb57fd394709c4a63` | `69cda5c26fb44c6680f6eafb41b5743a` | `GymRegisterPage` + `StitchKineticCard` |
| Wizard 1–5 | `89e695b4…` / `9dfae0b2…` / `7ddcc183…` / `f3635eac…` / `a5827af5…` | twins | `GymOnboardingWizardPage` + connected stepper |
| Settings Profile | `28a6e5e325164b70a9a139f4599832c4` | `fc6cb55221c94031a4b8bf9c1ca42be9` | Settings pills → wizard (hub module, **ignore** Settings rail) |

### Regions (Register)

| Region | Stitch | Flutter |
|--------|--------|---------|
| Canvas | `#121212` | `KineticTokens.deepCharcoal` |
| Top bar | PULSE + EN/AR | `StitchPulseTopBar` |
| Card | ~720, lime 2px edge | `StitchKineticCard` |
| Title | CREATE YOUR GYM ACCOUNT | `onboarding.register.title` 32/w900 |
| Fields | filled `#121212` radius 8 | `StitchFilledField` |
| CTA | full-width lime 52 | `StitchLimeCta` |
| Helper | staff-invite callout | `onboarding.register.staff_note` |

**Ignore:** `FITBIT_JUBING_JACKS`, “Must be facility domain”.

### Regions (Wizard)

| Region | Stitch | Flutter |
|--------|--------|---------|
| Connected stepper | lime line + numbered nodes | `StitchConnectedStepper` (`gym-profile-step-*`) |
| Stage badge | STAGE 0n | `StitchStageBadge` |
| Dashed uploads | logo/banner | `StitchDashedUpload` |
| Footer | Back + lime Next | `StitchGhostButton` + `StitchLimeCta` |

## FEAT-97 screens

| Surface | EN | AR | Flutter |
|---------|----|----|---------|
| Operations | `aa6f5bb356214f67b22ab8e840f12d96` | `a718b3ad19fd4640adf2ceebc77ddf1f` | `GymOperationsScreen` |
| Gun banner | `8b38c6168f824bebab709b919f2dc24f` | `210e882c2bb44d71bac5aa78a1e0a493` | `DeskGunReadyBanner` |
| G1 camera | `3629845f7f1e402697f46cf5575e86da` | `bec9356e2cb941798e66fa804ac78854` | existing Check-in Gate |

### Design gaps

1. Settings / Access Scanner **rails** → ignore. Operations is a hub **pill**. Scanner stays Home → Access Scanner.
2. Save chrome **SAVE INGESTION POLICY** → product **Save**.
3. Junk (`CAI-FLAGSHIP-01`, Capt. Tarek, occupancy 42/100) → not copy.
4. Lime targeting reticle is a **graphic**, not a mounted camera.

### Regions (Operations)

Three radio cards (HID recommended · webcam · hybrid default), helper, lime Save. Admin-only write.

### Regions (Gun)

Ready pill, headline, empty last-member, coral invalid swatch, Use camera (hybrid). **No** black video box.
