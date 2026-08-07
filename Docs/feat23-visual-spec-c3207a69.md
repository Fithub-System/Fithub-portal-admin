# Visual Spec Card — Marketing & Promotions (FEAT-23)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-23 Portal Marketing |
| Stitch project | `13435235862240753621` |
| Screen id | `c3207a6938bf40a7872dde7532020ef9` |
| Stitch title | Marketing & Promotions |
| Platform | DESKTOP |
| EN twin / AR twin ids | EN `c3207a6938bf40a7872dde7532020ef9` · AR `ced3126ee9584f86b8c0877d4b20a8d8` · companion RTL/LTR `5fc938e1f95843d5b9c644bc2f01a63a` (optional) |
| MCP tools used | HTTP JSON-RPC `tools/call` → `get_screen` on `https://stitch.googleapis.com/mcp` (Cursor catalog omitted `user-stitch`; OAuth Bearer via `gcloud auth print-access-token` + `X-Goog-User-Project: fithub-503813`) |
| Fetched at (UTC) | 2026-08-07T15:05:00Z |
| Author agent | Portal Admin Agent |

---

## Frame

| Field | Stitch value | Notes |
|-------|--------------|-------|
| Width × height | `2560` × `2326` (EN) / `2560` × `2278` (AR) | DESKTOP artboard |
| Page background | `#131313` | Kinetic `stitchBackground` |
| Primary surface | `#1C1B1B` / `#0E0E0E` | Flash Sale / promo cards |
| Accent | `#CCFF00` / `#C3F400` | Deploy CTA / badges |
| Secondary accent | `#4A8EFF` | REACH / Conversion Flow |

Screenshot (MCP EN): `Docs/feat23-assets/stitch-en-screenshot.png`  
HTML (MCP EN): `Docs/feat23-assets/stitch-en.html`  
Screenshot (MCP AR): `Docs/feat23-assets/stitch-ar-screenshot.png`  
HTML (MCP AR): `Docs/feat23-assets/stitch-ar.html`

---

## Regions (top → bottom / start → end)

| # | Region name | Position / size | Padding | BG / border / radius | Flutter target widget |
|---|-------------|-----------------|---------|----------------------|------------------------|
| 1 | SideNavBar (6-rail) | Sticky start, Marketing active | shell | rail `#0A0A0A` | `_PortalNavigationRail` (FEAT-11 — unchanged) |
| 2 | TopNavBar | Sticky header | shell | blur charcoal | `_PortalShellHeader` |
| 3 | Growth Engine eyebrow | Main pad ~24 | — | cyber blue caps | `marketing.growth_engine` |
| 4 | PROMOTIONS & REACH title | Under eyebrow | — | white + blue REACH | `_GrowthHeader` |
| 5 | LIVE ANALYSIS pill | End of header | — | outline lime | `_GrowthHeader` |
| 6 | FLASH SALE form | Start column | `p-5` | `#1C1B1B` + lime start border | `FlashSaleCampaignForm` |
| 7 | CONVERSION FLOW | End column | `p-5` | chart fixture `42.8%` | `ConversionFlowCard` (**fixture** AC-D1) |
| 8 | ASSET LIBRARY | Mid start | h~160 | gradient gym chrome | `AssetLibraryCard` (**fixture** AC-D2) |
| 9 | ACTIVE PROMOS | Mid end | — | list + Create New Code | `ActivePromosPanel` |
| 10 | Promo cards | In list | — | ALPHA30 / FOUNDER / BOLT | live rows or Stitch sample fixtures |
| 11 | Metric tiles | Footer row | — | Reach / CTR / Revenue | `MarketingMetricTiles` (**fixture** AC-D1) |
| 12 | Billing / Charges | Below Growth Engine | — | FEAT-08 secondary | `BillingChargesSection` |

---

## Typography

| Role | Font | Size | Weight | Color | Line height | Stitch sample copy |
|------|------|------|--------|-------|-------------|--------------------|
| Eyebrow | Lexend/Inter | ~12 | extrabold caps | `#4A8EFF` | — | `GROWTH ENGINE` |
| Page title | Lexend | ~32 | black | white / blue | tight | `PROMOTIONS & REACH` |
| Flash Sale title | Lexend | ~22 | extrabold | white | — | `FLASH SALE` |
| Form labels | Inter | 11 | bold caps | `#C4C9AC` | — | `CAMPAIGN NAME` |
| Deploy CTA | Inter | 14 | extrabold | black on lime | — | `DEPLOY CAMPAIGN` |
| Promo code | Inter | 16 | extrabold | white | — | `ALPHA30` |
| Metric value | Lexend | ~26 | black | white | — | `1.4M` |

---

## Components

| Component | Height | Radius | Fill | Border | Icon size | Notes |
|-----------|--------|--------|------|--------|-----------|-------|
| Deploy Campaign | 48 | 8 | `#CCFF00` | none | bolt 20 | Admin only |
| Text / date field | ~48 | 8 | `#0E0E0E` | muted | calendar 18 | Start/End windows |
| Push toggle | — | — | lime track | — | bell 22 | stores `push_enabled` |
| Create New Code | text btn | — | transparent | — | add 18 | Admin; opens dialog |
| Promo badge | — | 4 | lime / blue / error | — | — | `% OFF` / LIFETIME / EXPIRED |
| Metric tile | — | 12 | `#0E0E0E` | muted | 28 | fixture values |

---

## States present in Stitch

| State | Screen id or section | Behavior |
|-------|----------------------|----------|
| Empty promos | ACTIVE PROMOS | Stitch sample rows (fixture) until live list non-empty |
| Loading | — | Lime spinner until first load |
| Error | load failure | Retry + message key |
| Disabled write | Receptionist | Deploy / Create disabled + read-only hint |
| Soft-end campaign | Campaign list | Admin End campaign → `status=ended` |

---

## Allowed deltas (only these)

| Delta | Reason |
|-------|--------|
| SafeArea / keyboard / scroll | Platform |
| Live campaigns/promos vs Stitch sample codes | Binding |
| Analytics / Asset Library fixtures | AC-D1 / AC-D2 |
| Secondary Billing / Charges section | FEAT-08 coexistence (not on Stitch artboard) |
| Push send / FCM | Residual — toggle persisted only |

---

## Side-by-side evidence (fill before PR)

| Artifact | Path / URL |
|----------|------------|
| Stitch screenshot (from MCP) | `Docs/feat23-assets/stitch-en-screenshot.png` |
| Stitch AR screenshot | `Docs/feat23-assets/stitch-ar-screenshot.png` |
| App screenshot | Widget-test region evidence (`test/feat23_marketing_test.dart`) — full device capture deferred to BizDev manual P1/P7 |
| Golden / region checklist | `Docs/feat23-marketing-region-checklist.md` |
