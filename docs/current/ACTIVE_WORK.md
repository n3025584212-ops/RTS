# FRONTLINE — ACTIVE WORK (POINTER + STANDING CONSTRAINTS)

STATUS=POINTER_ONLY
PROJECT=FRONTLINE《战线》
ROLE=POINTER_AND_STANDING_CONSTRAINTS

The active issue, branch, gate, task and window routing are stated in exactly one place:
`docs/current/CURRENT_STATE.md`. They are deliberately NOT repeated here — this file used to
carry them and drifted out of date (it still named `MINIMUM_ARMORED_UNIT_INTEGRATION` as the
current gate while main had already closed Gate D2).

## Standing constraints (long-lived, in force at every gate)

The high-fidelity River Town scene is the product construction mother scene. Gameplay integration
must move into this scene without degrading its terrain / material / architecture / vegetation /
lighting / atmosphere / water / camera pipeline.

```
NO_BOX_PROXY_BATTLEFIELD=YES
NO_CYLINDER_PROXY_BATTLEFIELD=YES
NO_COLOR_BLOCK_ENVIRONMENT=YES
NO_DEBUG_LABEL_DOMINATED_CAPTURE=YES
NO_LEARNING_SCENE_AS_PRODUCT_ANCESTOR=YES
RIVER_TOWN_VISUAL_FLOOR_PROTECTED=YES
NO_VISUAL_REGRESSION_BELOW_RIVER_TOWN_WITHOUT_EXPLICIT_APPROVAL=YES
```

Changing any of these requires a Window 00 decision recorded in the decision log.

## Stopped routes (do not reopen without an explicit user instruction)

Issue #39 / Sprint01 learning-test visual iteration is closed as an active product route.
`res://scenes/learning/sprint01/Sprint01WorldReproduction.tscn` is evidence only. Validated
Sprint01 gameplay/runtime logic may be transferred into the product scene; the learning scene
itself must not be extended into it.

## Where to read state

- Control state — stage / gate / window / head ... `docs/current/CURRENT_STATE.md`
- Gate contract and PASS requirements ......... `docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md`
- Decision history ............................ `docs/current/DECISION_LOG.md`
- Visual quality baseline ..................... `docs/current/VISUAL_QUALITY_BASELINE.md`
