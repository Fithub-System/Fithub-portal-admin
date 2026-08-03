# FEAT-16 VF3 — Staff Region Checklist

**Stitch source:** HTTP MCP `get_screen` 2026-08-03T20:40:00Z  
**Stitch assets:** `Docs/feat16-vf3-assets/stitch-dcc070ef-screenshot.png`, `stitch-dcc070ef.html`  
**Spec Card:** `Docs/feat16-vf3-visual-spec-dcc070ef.md`

| Region / element | Stitch | Flutter | Δ px / notes |
|------------------|--------|---------|--------------|
| Page BG | `#131313` | `KineticTokens.stitchBackground` | 0 |
| Title `STAFF PROFILE CREATOR` | Lexend black ~48 uppercase | `staff_invite.title` | match |
| Subtitle | on-surface-variant lg | `staff_invite.subtitle` | match |
| Lime left border header | `#C3F400` 4px | `StaffProfileHeader` | match |
| Active Shifts | `14` on `#2A2A2A` | fixture chrome | §4.1 |
| Identity card | `#1C1B1B` + watermark | name/email/emergency/specialization | Emergency/Spec chrome |
| Access Protocol | Admin / Trainer / Front Desk | role toggles; API Coach/Receptionist | FEAT-05 |
| Initialize Profile | white CTA | invite submit when `canInvite` | FEAT-05 |
| Shift Log title + CTAs | schedule + Export/Filter | `StaffShiftLogHeader` | Filter/Export chrome |
| Col Staff Member | avatar + name + email | initials + fixture | §4.1 |
| Col Role | Trainer/Admin/Front Desk chips | `_RoleChip` | match |
| Col Clock-In/Out | mono times / `--:--` | fixture (Stitch chrome, not blank —) | §4.1 |
| Col Total Hours | 8.35h / 6.00h / 8.00h / 4.00h | Lexend bold | match |
| Col Status | lime pulse / muted | `_StatusDot` | match |
| Sample rows | Elena / Marcus / Sarah / Alex | `StaffStitchFixtures.shiftRows` | §4.1 |
| Recent Audit Actions | 2 timeline items | `StaffAuditFeed` | §4.1 |
| Security Compliance | lime tile + System Secure | `StaffSecurityComplianceTile` | §4.1 |
| 6-rail IA | Staff active | `PortalShellDestinations` ×6 | unchanged |

## Side-by-side

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf3-assets/stitch-dcc070ef-screenshot.png` |
| AR twin screenshot | `Docs/feat16-vf3-assets/stitch-6388be39-ar-screenshot.png` |
| Widget evidence | `test/feat16_vf3_staff_fidelity_test.dart` |

## Notes

- Cursor MCP `user-stitch` **not** injected; fetch via authenticated HTTP (`gcloud` OAuth + quota project).
- §4.1 confirmed: Shift Log / audit / security / Active Shifts always ship fixtures — never blank table / bare `—` (clock-out `--:--` is Stitch sample).
- FEAT-05: name + email + role still invite via Edge Function when Admin.
