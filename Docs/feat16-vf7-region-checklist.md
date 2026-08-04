# FEAT-16 VF7 — Login Region Checklist

**Stitch source:** HTTP MCP `list_screens` + `get_screen` 2026-08-04T08:03:19Z  
**Stitch assets:** `Docs/feat16-vf7-assets/stitch-c12b687f-screenshot.png`, `stitch-c12b687f.html`  
**Spec Card:** `Docs/feat16-vf7-visual-spec-c12b687f.md`

| Region / element | Stitch | Flutter | Δ px / notes |
|------------------|--------|---------|--------------|
| Page BG | `#131313` | `AppColors.background` | 0 |
| Ambient orb | 800×800 lime blur | `_AmbientGlow` ImageFiltered | ~match |
| Brand | `GYM CONNECT` 48 / 900 | `login-brand` | match |
| Subtitle | Command Center Login uppercase | `login-subtitle` | match |
| Card surface | `#1C1B1B` p-8 r-4 | `login-card` | match |
| Kinetic top edge | 2px lime gradient | `login-card-kinetic-edge` | match |
| Credential field | person + underline hint | `login-credential-field` | match |
| Access Key + Recover | lock + secondary link | fields + `login-recover-key` | match |
| Initialize CTA | kinetic py-4 + arrow | `login-cta-initialize` h56 | match |
| CTA top hairline | white/30 | Stack overlay | match |
| Or via social | divider + uppercase | `login-or-social` | match |
| Google / Apple | both buttons | social keys | §4.1 chrome |
| Footer Privacy / Terms | gap-6 | `login-footer` gap 24 | match |
| Copyright | 10px muted | `login-copyright` | match |
| Locale EN\|AR | absent in Stitch | top-end chips | allowed FEAT-03 |
| Obscure toggle | absent in Stitch | visibility icon | allowed UX |

## Side-by-side

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf7-assets/stitch-c12b687f-screenshot.png` |
| AR twin screenshot | `Docs/feat16-vf7-assets/stitch-0f33f746-ar-screenshot.png` |
| Widget evidence | `test/feat16_vf7_login_fidelity_test.dart` |

## Notes

- Cursor MCP `user-stitch` **not** injected; fetch via authenticated HTTP (`gcloud` OAuth + quota project).
- §4.1 confirmed: brand, card chrome, Recover, social buttons, footer, copyright always ship — never blank/`—` shells.
- FEAT-02 AuthBloc sign-in + snackbar errors preserved; FEAT-05 invite lives under Staff rail (not this surface).
