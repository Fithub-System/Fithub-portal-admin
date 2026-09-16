# Visual Spec Card — FEAT-92 CHECK_OUT banner variant (G1)

## Meta

| Field | Value |
|-------|-------|
| FEAT | FEAT-92 Portal HF-2 |
| Stitch project | `13435235862240753621` |
| Screen id | G1 EN `3629845f7f1e402697f46cf5575e86da` · AR `bec9356e2cb941798e66fa804ac78854` |
| Overview ring | `216e0407184f4c39bd501ed436c1e88b` |
| Author | Portal Admin Agent |

## Design gap (locked)

G1 is titled Check-in Gate. Stitch has **no** dedicated CHECK_OUT artboard. CHECK_OUT is a **success-banner state** on G1.

| Variant | Copy EN | Copy AR | Occupancy |
|---------|---------|---------|-----------|
| CHECK_IN | Checked in | تم تسجيل الدخول | RPC recount |
| CHECK_OUT | Checked out | تم تسجيل الخروج | RPC recount (decrement) |

Name, photo, membership badge retained from FEAT-01/16 VF4. Ring reads `gyms.current_occupancy` after toggle (FEAT-04).
