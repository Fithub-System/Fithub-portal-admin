# FEAT-18 Class Manager — Region Checklist (§E2)

**Stitch EN:** `40cc7e5d1f27417f9e6681c0fe14b180`  
**Stitch AR:** `3f356939493b4a79980687040e5e4fa2`  
**Spec Card:** `Docs/feat18-visual-spec-40cc7e5d.md`

| # | Region | Stitch present | Flutter present | Evidence |
|---|--------|----------------|-----------------|----------|
| 1 | FEAT-11 6-rail Classes active | Yes | Yes (unchanged IA) | `PortalShellDestinations.classes == 3` |
| 2 | WEEKLY SCHEDULE title | Yes | Yes | Widget test + `ClassManagerScreen` |
| 3 | Week range + Today / chevrons | Yes | Yes | `_WeekNav` |
| 4 | Time × day grid 06–12 | Yes | Yes | `ClassWeeklyScheduleGrid` |
| 5 | Session cards title + coach | Yes | Yes | `_SessionCard` |
| 6 | Schedule New empty chrome | Yes | Yes (Admin / empty week Wed 09) | `_EmptySlot` |
| 7 | Add New Session form | Yes | Yes | `ClassSessionFormPanel` |
| 8 | Class Type / Instructor / Max Capacity | Yes | Yes | Form fields + i18n |
| 9 | Create Class CTA | Yes | Yes (Admin) | Disabled when `!canWrite` |
| 10 | Detail Active Now / capacity / attendees | Yes | Yes (fixtures) | `ClassSessionDetailPanel` + `ClassManagerStitchFixtures` |
| 11 | Bulk Check-In chrome | Yes | Yes (non-functional) | Outlined button disabled |
| 12 | Coming soon superseded | — | Yes | Classes destination → `ClassManagerScreen` |

## Side-by-side

| EN Stitch | AR Stitch |
|-----------|-----------|
| `Docs/feat18-assets/stitch-en-screenshot.png` | `Docs/feat18-assets/stitch-ar-screenshot.png` |

App device screenshot: deferred to manual guide P6; automated region assertions in `test/feat18_class_manager_test.dart`.
