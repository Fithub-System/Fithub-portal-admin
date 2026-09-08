# Visual Spec Card — FEAT-59 Empty-slot Schedule New + Add Member center

## Meta

| Field | Value |
|-------|-------|
| FEAT / phase | FEAT-59 Portal Members live + Classes day-cell IA |
| Stitch project | `13435235862240753621` |
| Members screen id | `9b35dd57f15443e99f7e798f6867acb6` |
| Add Member EN / AR | `cd59a129a24449478a5249ccb41635fb` / `89fe5d7afb8d4d4384d7e6498bcdd065` |
| Classes calendar | FEAT-18 Class Manager EN `40cc7e5d1f27417f9e6681c0fe14b180` |
| MCP tools used | Unavailable in session catalog (`user-stitch` missing) — cite locked ids + FEAT-18 empty-slot chrome |
| Fetched at (UTC) | 2026-09-08 |
| Author agent | Portal Admin Agent |

---

## Regions changed (FEAT-59)

| # | Region | Change | Flutter target |
|---|--------|--------|----------------|
| 1 | Members roster body | Empty live roster → empty chrome + Retry (no Dominic/Sarah sample rows) | `_EmptyRosterChrome` |
| 2 | Members open | Cloud refresh then present | `MemberRosterCubit.refreshFromCloud` from shell |
| 3 | Add Member form shell | Horizontally centered; max-width 720 preserved | `Align` + `ConstrainedBox` on `AddMemberScreen` |
| 4 | Classes empty day/hour cell | Full Schedule New chrome on **hover/focus**; subtle `+` idle; tap → existing schedule flow — **all** Admin empty cells (not Wed 09 only) | `_EmptySlot` / `ClassWeeklyScheduleGrid` |

---

## Empty-slot chrome (Stitch language)

| State | Visual |
|-------|--------|
| Idle (Admin, empty) | Muted `+` icon (~16px, zinc ~35% opacity) |
| Hover / focus | Dashed/outline container, lime `+` 18px + `SCHEDULE NEW` 8px uppercase |
| Tap / activate | Existing `onScheduleSlot` → draft slot + Add New Session form |
| Receptionist | No write chrome (unchanged) |

---

## Add Member center

| Field | Value |
|-------|-------|
| Max width | `720` (`AddMemberScreen.formMaxWidth`) |
| Alignment | `Alignment.topCenter` |
| Stitch IA | No new fields / tabs — centering only |

---

## Forbidden

- Masking empty live roster with `MembersStitchFixtures.sampleRows`
- Wed-09-only Schedule New restriction
- New freehand schedule dialog
