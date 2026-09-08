# Visual Spec Card — FEAT-62 Add Member Invite (live)

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-62 US-B |
| Stitch project | `13435235862240753621` |
| Screen title | Add New Member |
| Platform | DESKTOP |
| EN screen id | `cd59a129a24449478a5249ccb41635fb` |
| AR screen id | `89fe5d7afb8d4d4384d7e6498bcdd065` |
| MCP tools used | Cursor `user-stitch` unavailable this session — citations reuse FEAT-13 / FEAT-16 VF2 locked G4 ids |
| Author agent | Portal Admin Agent |
| Date (UTC) | 2026-09-08 |

## Intent

Replace the Invite **stub** with a live form that calls Edge `invite-member`.
**Link existing** tab (FEAT-13 Flow A) is unchanged.

## Regions (Invite tab)

| # | Region | Flutter target | Notes |
|---|--------|----------------|-------|
| 1 | Tabs Link / Invite | `AddMemberScreen` `TabBar` | Kinetic lime indicator |
| 2 | Invite heading + body | `_InviteMemberTab` | Explains email/username + 48h OTP |
| 3 | Identifier field | email **or** username | `@` → email path |
| 4 | Display name (optional) | text field | |
| 5 | Plan (optional) | dropdown | Applied on Athlete OTP verify |
| 6 | Send invite CTA | filled lime | Not disabled stub |
| 7 | Visual Spec citation | footer line | This card path |

## Tokens

Kinetic Monolith: deep charcoal `#131313`, electric lime `#CCFF00`, gunmetal cards.
Matches locked Add New Member Stitch (G4) — no new artboard.

## Out of scope (this card)

- Athlete OTP UI (US-C)
- Guest Insights live bind (optional residual)
