# FRONTLINE — HIGH FIDELITY PRODUCT SLICE V1

STATUS=ACTIVE_CONSTRUCTION_CONTRACT
ACTIVE_ISSUE=#41
ACTIVE_BRANCH=product/frontline-high-fidelity-slice-v1
PRIMARY_SCENE=res://scenes/production/RiverTownVisualSlice.tscn
ENGINE=Godot 4.7.1
RENDERER=Forward+
TARGET_CAPTURE=1920x1080

## Gate A — River Town baseline reproduction

STATUS=PASS

Validated workflow:
- workflow: `FRONTLINE River Town Visual Slice`
- run: `#7`
- run id: `35325714573`
- branch head: `7032c91ccd9c58244ce36f944558fa3dd4727d01`
- conclusion: `success`
- completed: `2026-09-18T08:49:23Z`

This closes the baseline-reproduction gate only. CI success is technical evidence, not final player-facing visual acceptance.

## Gate B — Current construction task

STATUS=GATE_B_PASS
CURRENT_GATE=MINIMUM_ARMORED_UNIT_INTEGRATION
OWNER_WINDOW=02_REPRODUCTION_AND_CONSTRUCTION
EVIDENCE_RECORD=product/frontline-high-fidelity-slice-v1::docs/visual_baseline/gate_b_20260920/EVIDENCE_RECORD.md
INDEPENDENT_AUDIT=product/frontline-high-fidelity-slice-v1::docs/current/GATE_C_AUDIT_GATE_B_V1.md (PASS_WITH_ONE_CONDITION, 2026-09-20)
CONDITION_CLOSED=product commit 394460d (capture driver tools/gate_b_capture.gd + original run log archived; EVIDENCE_RECORD.md amended)

Integrate the minimum already-validated controllable armored-unit/runtime chain into the real River Town product scene.

Required implementation rules:
1. Keep `RiverTownVisualSlice.tscn` as the product mother scene.
2. Reuse validated gameplay/runtime logic; do not make the Sprint01 learning scene the product ancestor.
3. Preserve the River Town terrain, architecture, vegetation, PBR materials, lighting, atmosphere, water and camera pipeline.
4. No box/cylinder/color-block proxy battlefield delivery.
5. Player-facing evidence must come from a fresh Godot 4.7.1 Forward+ 1920x1080 runtime capture.
6. The controllable unit must visibly exist inside the high-fidelity scene and be operable through the validated control chain.
7. Any integration that causes a visible regression below the retained River Town floor is a fail until corrected or explicitly approved.

## Required evidence for Gate B PASS

- import/runtime completes without fatal error;
- minimum controllable armored unit is instantiated in River Town;
- control/movement chain is demonstrated in fresh runtime media;
- fresh 1920x1080 screenshot or video exists;
- visual comparison against `artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png` is recorded;
- no protected River Town subsystem is replaced by test proxies;
- branch/commit and workflow evidence are recorded here before advancing.

## Gate D — Product slice expansion (Window 00 authorized 2026-09-20, user directive "D1")

## Gate D1 — MINIMUM_COMBAT_CHAIN

STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT
EVIDENCE_RECORD=product/frontline-high-fidelity-slice-v1::docs/visual_baseline/gate_d1_20260920/EVIDENCE_RECORD.md
INTEGRATION_COMMIT=product/aedabe0

Contract: extend the Gate B armored-unit chain with the validated combat cycle inside the
River Town mother scene — one static RED hostile armored unit (real GLB, no proxy), attack
order routing through `set_combat_target` -> `_update_combat` (range/cooldown/ammo/validated
damage matrix), visible damage progression, destruction state, fresh 1920x1080 media, and a
committed evidence driver. Known limitations recorded in the evidence record (static hostile,
no LOS field binding, tracer lifetime vs frame rate).

PASS requirements: import/runtime clean; hostile instantiated as real PBR asset; fire cycle
demonstrated in fresh media with matrix-consistent damage and ammo accounting; destruction
state visible; no regression below the River Town floor; independent audit (Gate C protocol)
before formal closure.

## Gate C — Independent audit

STATUS=CLOSED
AUDIT_REPORT=product/frontline-high-fidelity-slice-v1::docs/current/GATE_C_AUDIT_GATE_B_V1.md
RESULT=PASS_WITH_ONE_CONDITION (condition satisfied by product commit 394460d)
AUDIT_HIGHLIGHTS=zero same-renderer pixel regression between pre/post-integration CI renders (runs 35325714573 vs 35464759495); no proxy leakage; capture reads as a real RTS product slice.
OWNER_WINDOW=03_INDEPENDENT_REVIEW

After Gate B produces fresh high-fidelity runtime media, Window 03 independently checks:
- visual regression;
- gameplay presence and control validity;
- proxy leakage;
- whether the result still reads as a real RTS product slice rather than a test scene.

## Routing

WINDOW_00=CONTROL_AND_ROUTING
WINDOW_01=HOLD_LEARNING_EVIDENCE_ONLY
WINDOW_02=ACTIVE_MINIMUM_ARMORED_UNIT_INTEGRATION
WINDOW_03=HOLD_PENDING_FRESH_RUNTIME_EVIDENCE

NEXT_REQUIRED_DELIVERABLE=FRESH_HIGH_FIDELITY_RIVER_TOWN_RUNTIME_WITH_CONTROLLABLE_ARMORED_UNIT
