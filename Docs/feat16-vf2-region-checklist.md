# FEAT-16 VF2 — Members Region Checklist

**Stitch source:** HTTP MCP `get_screen` 2026-08-03T20:19:32Z  
**Stitch assets:** `Docs/feat16-vf2-assets/stitch-9b35dd57-screenshot.png`, `stitch-9b35dd57.html`  
**Spec Card:** `Docs/feat16-vf2-visual-spec-9b35dd57.md`

| Region / element | Stitch | Flutter | Δ px / notes |
|------------------|--------|---------|--------------|
| Page BG | `#131313` | `KineticTokens.stitchBackground` | 0 |
| Title `ACTIVE ROSTER` | italic black ~48 | `members.title` | match |
| Subtitle | on-surface-variant | `members.subtitle` | match |
| Filter Type CTA | surface-high + outline | `members.cta.filter_type` → plans sheet | FEAT-07 bind |
| Add New Member CTA | `#C3F400` | `add_member.cta.add_new` | enabled iff `canEnroll` |
| Elite Tier tile | 124 + lime left border | fixture / live elite count | §4.1 |
| Avg XP Level | 68.2 | fixture / live avg powerScore | §4.1 |
| Active Sessions | 42 | fixture chrome | unbound metric |
| System Health | Optimal on `#4A8EFF` | fixture chrome | unbound metric |
| Col Member Name | avatar + name + ID | initials + `membersDisplayId` | match |
| Col Plan Type | Elite/Standard/Basic chips | `_PlanChip` | match |
| Col XP Level | bar + value | gradient bar + powerScore | match |
| Col Actions | Freeze · Renew · Full Evaluation | same labels; Full Eval → Assign if canWrite | FEAT-07 |
| Sample rows (empty cache) | Dominic / Sarah / Jason / Elena | `MembersStitchFixtures.sampleRows` | §4.1 |
| Pagination | Showing 1-10 of 1,240 | fixture copy when empty | §4.1 |
| Sync footer | Sync Active · API V2.4 · © | `MembersSyncFooter` | match |
| No Roster/Plans tabs | absent | `TabBar` absent | AC-A4 |
| 6-rail IA | Members active | `PortalShellDestinations` ×6 | unchanged |

## Side-by-side

| Artifact | Path |
|----------|------|
| Stitch screenshot (MCP) | `Docs/feat16-vf2-assets/stitch-9b35dd57-screenshot.png` |
| Widget evidence | `test/feat16_vf2_members_fidelity_test.dart` |

## Notes

- Cursor MCP `user-stitch` **not** injected; fetch via authenticated HTTP (`gcloud` OAuth + quota project).
- §4.1 confirmed: empty Drift cache ships fixture rows/stats/pagination — never blank table / bare `—`.
