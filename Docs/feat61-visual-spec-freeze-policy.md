# FEAT-61 — Freeze policy settings — Visual Spec Card

**Status:** Nested under Gym Settings (no dedicated Stitch freeze screen)  
**FSD:** `Fithub-documentation/specs/FEAT-61-MEMBERSHIP-RENEW-FREEZE.md` US-C  
**Parent Stitch:** Gym Settings / SKU & Marketplace G2  
- EN `6cb93d6100314ce8a5d9c1af92c97723`  
- AR `9541b6e764dd436daa91336b0ce2263b`  

## Placement

- **Entry:** Avatar menu / Reports nest → Gym Settings (existing FEAT-10 IA).  
- **Not** a new rail destination.  
- Section appears **below** SKU mode + Marketplace after Save SKU CTA.

## Composition (one job)

1. Heading: **FREEZE POLICY** (+ short subtitle).  
2. Visual Spec citation line (this card path).  
3. **General** card: default freeze days + max days per request + Save.  
4. **Per-plan** card: plan dropdown + same fields + Save (override).  
5. Read-only list of configured policies.  
6. Receptionist: fields disabled + read-only hint (Admin write only).

## Tokens

Reuse Kinetic Gym Settings: `deepCharcoal` / `surfaceContainerLow` / `electricLime` CTAs / zinc muted labels. No new brand language.

## EN / AR

Keys under `gym_settings.freeze.*` in `assets/translations/{en,ar}.json`.
