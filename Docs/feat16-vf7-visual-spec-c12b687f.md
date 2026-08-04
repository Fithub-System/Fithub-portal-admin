# Visual Spec Card — Web Admin Login Portal

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-16 VF7 |
| Stitch project | `13435235862240753621` |
| Screen id | `c12b687f1538452ebaf8d0adb89a9489` |
| Stitch title | Web Admin Login Portal |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `c12b687f1538452ebaf8d0adb89a9489` · AR `0f33f7463ca543c7b85bcb8637249f65` |
| MCP tools used | HTTP JSON-RPC `tools/call` → `list_screens`, `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`; `get_screen` requires `name=projects/{id}/screens/{sid}`) |
| Fetched at (UTC) | 2026-08-04T08:03:19Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2048` | DESKTOP artboard (EN) |
| AR frame | `2560` × `2048` | RTL twin |
| Page background | `#131313` | `background` / `surface` |
| Primary surface | `#1C1B1B` | `surface-container-low` (login card) |
| Surface container | `#201F1F` | social buttons |
| Highest / outline | `#353534` / `#444933` | divider / field underline |
| Lime accent | `#C3F400` → `#ABD600` | `kinetic-gradient` CTA |
| On-CTA | `#556D00` | `on-primary-container` |
| Secondary link | `#ADC7FF` | Recover Key |

Screenshot (MCP): `Docs/feat16-vf7-assets/stitch-c12b687f-screenshot.png`  
HTML (MCP): `Docs/feat16-vf7-assets/stitch-c12b687f.html`  
AR screenshot: `Docs/feat16-vf7-assets/stitch-0f33f746-ar-screenshot.png`  
AR HTML: `Docs/feat16-vf7-assets/stitch-0f33f746-ar.html`  
Meta: `Docs/feat16-vf7-assets/stitch-c12b687f-meta.json`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | Ambient lime orb | centered `800×800`, blur ~150 | — | `#C3F400` @ ~10% inside 30% layer | `_AmbientGlow` |
| 2 | Brand header | center, above card | `mb-12` (48) | — | `login-brand` + `login-subtitle` |
| 3 | Login card | `max-w-md` (448) | `p-8` (32) | `#1C1B1B`, `rounded-lg` (4), ambient-glow | `login-card` |
| 4 | Kinetic top edge | full card width | `h-0.5` (2) | lime gradient | `login-card-kinetic-edge` |
| 5 | Credential Identifier | form column | label+field `gap-2` | underline `#444933`/30 | `login-credential-field` |
| 6 | Access Key + Recover | label row + field | Recover end/link | secondary underline | `login-access-key-field` + `login-recover-key` |
| 7 | Initialize Session CTA | full width | `py-4` (~56) | lime gradient, `rounded-md` (6), white/30 top hairline | `login-cta-initialize` |
| 8 | Social divider | `mt-10 mb-8` | px-4 chip | `#353534` rule | `login-or-social` |
| 9 | Social buttons ×2 | `gap-3` (12) | `py-3` | `#201F1F` + outline/15, radius 6 | `login-social-google` / `apple` |
| 10 | Footer links | `mt-12` | `gap-6` (24) | muted xs | `login-privacy` / `login-terms` |
| 11 | Copyright | under links | `mt-6` | 10px uppercase muted | `login-copyright` |

Locale EN\|AR chips (top-end) are **not** on the Stitch artboard — FEAT-03 required delta.

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Brand | Lexend display | `text-5xl` (~48) | black / 900 | `#FFFFFF` | tight / tracking-tighter | `GYM CONNECT` (uppercase) |
| Subtitle | Inter / Cairo | `text-sm` (14) | medium | `#C4C9AC` | tracking-widest uppercase | EN `COMMAND CENTER LOGIN` · AR `مركز قيادة تسجيل الدخول` |
| Field label | Inter label | ~12 / xs | 600 | `#C4C9AC` | tracking-widest uppercase | `CREDENTIAL IDENTIFIER` / `ACCESS KEY` |
| Field value | Inter body | 16 | regular | `#FFFFFF` | — | placeholder `Email or Username` / `••••••••` |
| Recover Key | Inter | 12 | regular | `#ADC7FF` underline | — | `Recover Key` |
| CTA | Lexend | 14 | bold | `#556D00` | tracking-wide uppercase | `INITIALIZE SESSION` + arrow |
| Social divider | Inter | 12 | regular | `#C4C9AC` | tracking-widest uppercase | `OR VIA SOCIAL LINK` |
| Social CTA | Inter | 14 | regular | `#FFFFFF` | — | Continue with Google / Apple |
| Footer | Inter | 12 / 10 | regular | variant / highest | tracking-widest on © | Privacy Protocol · Terms · © 2024… |

AR twin brand remains Latin `GYM CONNECT` in Stitch HTML; EasyLocalization AR fields/CTAs match twin Arabic.

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Login card | content | 4 (`lg`) | `#1C1B1B` | ambient glow shadow | — | kinetic 2px top edge |
| Underline field | content + py-3 | — | transparent | bottom outline-variant/30 | person/lock 20 | focus → lime |
| Primary CTA | ~56 (`py-4`) | 6 (`md`) | kinetic gradient | white/30 top hairline | arrow 18 | loading spinner FEAT-02 |
| Social button | ~48 (`py-3`) | 6 | `#201F1F` | outline-variant/15 | login / devices 18 | snackbar OOS stub |
| Recover link | text | — | — | underline | — | snackbar unavailable stub |

---

## Fixture sample content (§4.1 — REQUIRED)

Marked `fixture` / artboard chrome. Must render — **not** blank/`—` shells.

| Kind | Stitch sample (EN) |
|------|---------------------|
| Brand | `GYM CONNECT` |
| Subtitle | `COMMAND CENTER LOGIN` |
| Credential label + hint | `CREDENTIAL IDENTIFIER` · `Email or Username` |
| Access Key | label + masked `••••••••` placeholder |
| Recover Key | visible link (non-routing stub OK) |
| CTA | `INITIALIZE SESSION` + forward arrow |
| Social divider | `OR VIA SOCIAL LINK` |
| Social Google / Apple | both controls visible (OOS snackbar OK) |
| Footer | `Privacy Protocol` · `Terms of Access` |
| Copyright | `© 2024 KINETIC PERFORMANCE SYSTEMS. ALL RIGHTS RESERVED.` |
| Ambient + kinetic edge | orb blur + lime top hairline |

AR twin mirrors RTL (`dir=rtl`); CTA arrow flipped; Arabic copy from twin HTML.

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty / idle | primary artboard | hints + empty fields + full chrome |
| Loading | product (FEAT-02) | CTA spinner replacing label — not drawn in Stitch |
| Error | product (FEAT-02) | `StitchAuthSnackbar` error_container — not a Stitch artboard |
| Disabled / OOS | social + recover | controls visible; snackbar explains OOS |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard | Platform |
| Scroll overflow | Content > viewport |
| EN\|AR locale chips | FEAT-03 i18n (not on artboard) |
| Password visibility toggle | Platform UX; Stitch shows static mask |
| Social / Recover non-routing | Out of scope; chrome required §4.1 |
| Live auth errors via snackbar | FEAT-02 contract |
| AR brand Latin `GYM CONNECT` | Matches Stitch AR HTML (not Arabic transliteration) |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat16-vf7-assets/stitch-c12b687f-screenshot.png` |
| AR twin screenshot | `Docs/feat16-vf7-assets/stitch-0f33f746-ar-screenshot.png` |
| Region checklist | `Docs/feat16-vf7-region-checklist.md` |
| Golden / region checklist | `test/feat16_vf7_login_fidelity_test.dart` |
