# Visual Spec Card — FEAT-91 pass_kind (additive, Members plans panel)

## Meta

| Field | Value |
|-------|-------|
| FEAT | FEAT-91 Portal HF-1 |
| Stitch project | `13435235862240753621` |
| Screen id | `9b35dd57f15443e99f7e798f6867acb6` (Members) |
| AR twin | `60b6a0e1f7fb4419b1b0e774ec8bdb32` |
| Author | Portal Admin Agent |

## Design gap (locked)

`pass_kind` is an additive field on the existing nested Plans create sheet. No new Stitch artboard. Tokens reuse Kinetic Members panel (`gunmetalCard`, lime CTA).

| Element | Implementation |
|---------|----------------|
| Pass type dropdown | `Key('memberships_pass_kind')` — Single Branch \| Roaming |
| EN/AR | `memberships.field.pass_kind` · `memberships.pass_kind.*` |
| Plan tile | Shows pass kind under duration/price |

Checkout Stitch EN/AR (`f83e87a0…` / `ccebeafe…`) is Athlete-owned.
