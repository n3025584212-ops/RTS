# FRONTLINE — SPRINT 01 WINDOW 02 FRESH RUNTIME EVIDENCE AUDIT V1

STATUS=FINAL
TASK_ID=AUDIT_WINDOW02_FRESH_RUNTIME_EVIDENCE_V1
WINDOW_ID=03
WINDOW_ROLE=INDEPENDENT_REVIEW_AND_FALSIFICATION
AUDIT_DATE=2026-09-15
ACTIVE_ISSUE=#39
AUDITED_BRANCH=learning/sprint01-end-to-end-rts-production
PRE_AUDIT_HEAD=0ccb59ccbb912c0fbb00f0aa68a5145be10d228e
IMPLEMENTATION_COMMIT=399b181fdf9b66bbd17ecded617ef7a124be8231
PARENT_AUDIT=docs/audit/AUDIT_SPRINT01_WINDOW02_REPRODUCTION_V1.md
PARENT_AUDIT_COMMIT=d88a434480d9f8568c68ab955dca1b93a8a2971a

EVIDENCE_PACKAGE=SPRINT01_RUNTIME_EVIDENCE_FOR_WINDOW03(1).zip
EVIDENCE_PACKAGE_SHA256=2b2cc06bdedcc76906c2268897c3903c39583d701efd9fab26160a039e5fa890

IMPLEMENTATION_AUDIT=PASS
RUNTIME_CAUSAL_CHAIN_AUDIT=PASS
EXACT_ASSET_RUNTIME_BINDING=PASS
FIRE_FEEDBACK_RUNTIME=PASS
OUTCOME_RUNTIME=PASS
RUNTIME_BLOCKER_VERDICT=RESOLVED_BY_FRESH_LOCAL_RUNTIME
PLAYER_LAYER_VERDICT=FAIL
REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_PLAYER_DELIVERY_CONTRACT_FAILED
NEXT_ROUTE=RETURN_TO_02_FOR_IMPLEMENTATION_FIX
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO

This audit intentionally separates successful runtime causality from player-facing delivery quality. The supplied fresh local run proves that the isolated source path executes and mutates state. It does not prove that the resulting visual slice satisfies the Sprint 01 delivery contract.

---

# 1. Evidence package integrity

The transferred package contains:

- `docs/learning/sprint01/REPRODUCTION_RESULT.md`
- `artifacts/learning/sprint01/runtime.log`
- `artifacts/learning/sprint01/input_injection.log`
- `artifacts/learning/sprint01/chain_extract.txt`
- `artifacts/learning/sprint01/exact_asset_binding.txt`
- `artifacts/learning/sprint01/fire_feedback.png`
- `artifacts/learning/sprint01/player_chain_final.png`
- `artifacts/learning/sprint01/player_chain.mp4`
- `WINDOW03_HANDOFF.txt`

Window 03 independently recomputed the file hashes. They match the hashes recorded in the result document for all seven runtime evidence files.

Video metadata independently observed:

```text
codec=h264
resolution=1600x900
fps=30
frames=286
duration=9.533333 s
```

The two PNG captures are both 1600x900 RGB images.

EVIDENCE_PACKAGE_INTEGRITY=PASS

---

# 2. Runtime execution and player input

## R01 — Godot actually started the isolated scene

VERDICT=PASS

The runtime log begins with:

```text
Godot Engine v4.7.1.stable.official.a13da4feb
OpenGL ... Compatibility ... llvmpipe
SPRINT01_REPRODUCTION_BOOT=YES
SCENE=res://scenes/learning/sprint01/Sprint01Reproduction.tscn
```

Both exact combat assets pass the runtime precheck as PackedScene and are instantiated as the BLUE Abrams and RED IFV entities.

The prior `CODE_EXECUTES=UNKNOWN` is therefore closed for this isolated run.

CODE_EXECUTES=PASS

## R02 — external input reaches the Godot input callback

VERDICT=PASS

The independent input log records external X11 XTest press/release events for key `1` and key `m` against a live `FRONTLINE (DEBUG)` X11 window.

The runtime log then records:

```text
INPUT_EVENT=KEY_1|CALLBACK=_unhandled_input|PRESSED=YES
SELECTED_ENTITY=BLUE_ABRAMS_01
INPUT_EVENT=KEY_M|CALLBACK=_unhandled_input|PRESSED=YES
COMMAND=ATTACK_MOVE
```

The evidence therefore closes the previous player-input runtime uncertainty without directly calling gameplay functions from the evidence harness.

PLAYER_INPUT_RUNTIME=PASS
COMMAND_RUNTIME=PASS

---

# 3. Movement / contact / combat / outcome

## R03 — command causes movement and contact

VERDICT=PASS

Observed runtime state:

```text
START_POSITION=(-18.000,0.180,-2.000)
COMMAND_TARGET=(8.000,0.180,-2.000)
MOVEMENT_STARTED=YES
END_POSITION=(3.966,0.180,-2.000)
CONTACT=RED_IFV_01|RANGE=10.03
MOVEMENT=PASS|DELTA=21.97
```

This is runtime state-change evidence, not a static-code inference.

MOVEMENT_RUNTIME=PASS
CONTACT_RUNTIME=PASS
STATE_CHANGED=PASS

## R04 — authoritative combat mutation and outcome

VERDICT=PASS

Four runtime fire events are observed. They mutate:

```text
ammo: 4 -> 3 -> 2 -> 1 -> 0
target HP: 100 -> 75 -> 50 -> 25 -> 0
```

The final runtime output contains:

```text
OUTCOME=TARGET_DESTROYED
COMBAT=PASS|SHOTS=4|AMMO=0|TARGET_HP=0
PLAYER_CHAIN_PASS=YES
FAILED_EDGE=NONE
```

COMBAT_RUNTIME=PASS
OUTCOME_RUNTIME=PASS

---

# 4. Logical fire -> visible feedback

## R05 — runtime event coupling

VERDICT=PASS

Each logical fire event is followed in the runtime log by the same-shot feedback event:

```text
VISIBLE_FEEDBACK_EVENT=SHOT_nn|MUZZLE=YES|TRACER=YES|IMPACT=YES|CAUSED_BY=FIRE_EVENT
```

On death, the runtime additionally reports wreck material, tilt, smoke and world label feedback.

This is consistent with the source-call audit in the parent review.

## R06 — independent visual inspection of fresh captures

VERDICT=PASS_FOR_FIRE_AND_OUTCOME_VISIBILITY

Window 03 directly inspected the transferred binary images and sampled the MP4.

Observed in `fire_feedback.png` / sampled video frames:

- a bright muzzle flash is visible near the firing Abrams position;
- a white/yellow tracer beam is visibly drawn toward the RED IFV;
- an orange impact/light effect is visibly present on/near the target;
- the target remains visibly identifiable as the RED IFV during combat.

Observed in `player_chain_final.png`:

- the IFV is visibly transformed to a dark wreck state;
- destruction smoke/effect geometry is present;
- `TARGET DESTROYED` and `PLAYER CHAIN COMPLETE` are visibly shown in the final UI/output state.

Therefore the previous `VISIBLE_FEEDBACK_RUNTIME=UNKNOWN` is closed.

FIRE_FEEDBACK_RUNTIME=PASS
OUTCOME_VISIBLE=PASS

Important: this does not make the entire PLAYER delivery layer PASS. The next section records the independent visual failures.

---

# 5. Exact real assets

## A01 — exact runtime asset identity

VERDICT=PASS

The package records the exact audited paths and Git blobs:

```text
Abrams:
assets/golden_scene/vehicles/mbt_abrams.glb
Git blob=24a1410d82c4d21e361f0f15caf0a04271e172bd
SHA256=54aa9adf650540847b603df15db159db74e74b9d0ad945c506e8010d8bc970d9

IFV:
assets/golden_scene/vehicles/ifv.glb
Git blob=ffe94b094a0d220a53671aa22f73cfe62b2401d7
SHA256=9f4cbe7d3efa11f57aff43e2ee11d896953ac4650827f562f0f631b708993656
```

Runtime precheck and runtime instance logs use the same exact paths.

There is no evidence that the reproduction substituted BoxMesh/CylinderMesh combat units for either audited vehicle.

EXACT_ASSET_RUNTIME_BINDING=PASS
REAL_COMBAT_UNIT_FALLBACK=NO

---

# 6. Independent PLAYER-layer falsification

The fresh run closes the causal-chain blocker but exposes visual/physical defects that prevent Sprint completion.

## F01 — BLUE Abrams is not player-readable as a main battle tank

VERDICT=FAIL
BLOCKING=YES

Across the transferred MP4 and the fresh screenshots, the BLUE Abrams is rendered as an extremely small yellow object / speck compared with the RED IFV.

At the pre-command and movement stages, the selection ring is large and obvious while the actual Abrams model inside/near it occupies only a tiny number of screen pixels. At contact/combat distance the Abrams remains a small yellow mark rather than a clearly readable MBT silhouette.

This means:

```text
EXACT_ASSET_INSTANTIATED=YES
PLAYER_CAN_READ_IT_AS_ABRAMS/MBT=NO
```

A real asset existing in the scene does not satisfy the player-facing real-unit requirement if its world-space presentation makes it effectively unreadable.

Possible causes include imported hierarchy transforms, asset bounds, or the reproduction's fitting logic, but no root cause is proven here.

ABRAMS_SCALE_OR_PRESENTATION_ROOT_CAUSE=UNKNOWN
REQUIRED_FIX=Correct world-space size/presentation so BLUE Abrams is visually identifiable and physically coherent with the IFV at the same battlefield scale.

## F02 — world labels materially occlude the gameplay image

VERDICT=FAIL
BLOCKING=YES_FOR_PLAYER_READABILITY

The large world-space labels:

- `BLUE APPROACH`
- `ABRAMS • PLAYER`
- `RED DEFENSIVE POSITION`
- `IFV • HOSTILE`
- `TARGET DESTROYED`

occupy a very large portion of the combat view and overlap the units and fire effects.

They demonstrate semantic state, but they also obscure the physical world. Diagnostic evidence text is being used in a way that degrades the very PLAYER-layer readability the Sprint is intended to test.

REQUIRED_FIX=Reduce/reposition/remove oversized world labels from the delivery view. Keep diagnostic evidence in HUD/logs without covering the battlefield.

## F03 — environment is still a primitive box/color-block delivery

VERDICT=FAIL
BLOCKING=YES

The Sprint 01 contract requires an independent reproduction with a causally reasonable real environment and explicitly forbids using boxes/color blocks as the delivery picture.

The fresh capture is dominated by:

- a flat plane/road surface;
- simple rectangular berms;
- simple rectangular defensive barriers;
- flat color materials;
- ring/guide primitives.

This is consistent with the implementation source, which builds much of the isolated environment through `PlaneMesh`, `BoxMesh`, rings and solid-color materials.

The real Abrams/IFV assets do not by themselves convert the surrounding primitive test world into a compliant real-environment delivery.

ENVIRONMENT_DELIVERY_CONTRACT=FAIL
REQUIRED_FIX=Use the already-audited real environment/content route or another provenance-recorded real content pipeline for the isolated reproduction. Do not change the gameplay causal chain merely to hide the defect.

## F04 — current fire feedback is visible but presentation quality is not yet production-like

VERDICT=PASS_WITH_DEFECT
BLOCKING_BY_ITSELF=NO

The tracer, muzzle and impact are genuinely visible. However they read as debug/prototype geometry: large emissive spheres, a stepped rectangular beam and strong diagnostic labeling.

This does not invalidate the runtime causal proof. It does mean the capture should not be promoted as representative FRONTLINE product-quality combat presentation.

PRODUCT_VISUAL_QUALITY_FROM_THIS_CAPTURE=NO

---

# 7. Reconciliation with Window 02 result document

Window 02's following runtime claims are independently supported:

```text
PLAYER_INPUT=PASS
COMMAND_ROUTE=PASS
MOVEMENT=PASS
CONTACT=PASS
COMBAT=PASS
VISIBLE_FEEDBACK=PASS  [narrow causal/visibility sense]
OUTCOME=PASS
CODE_EXECUTES=PASS
STATE_CHANGED=PASS
PLAYER_CHAIN_PASS=YES
```

However this Window 02 claim is too broad:

```text
PLAYER_LAYER=PASS
```

Window 03 downgrades it because player-facing unit readability and the environment delivery contract fail independent visual inspection.

Corrected interpretation:

```text
PLAYER_CAUSAL_INTERACTION_CHAIN=PASS
PLAYER_VISIBLE_FIRE_AND_OUTCOME=PASS
PLAYER_UNIT_READABILITY=FAIL
PLAYER_ENVIRONMENT_DELIVERY=FAIL
PLAYER_LAYER_OVERALL=FAIL
```

Therefore `REPRODUCTION_STATUS=REPRODUCED` is acceptable only if explicitly scoped to the causal runtime chain. It is not acceptable as the complete Stage-5/Stage-6 Sprint reproduction gate.

---

# 8. Runtime blocker disposition

The previous GitHub-hosted-runner blocker is no longer the active gate because this fresh local Godot 4.7.1 run executed the exact isolated reproduction with the exact audited combat assets.

```text
PREVIOUS_RUNTIME_BLOCKER=RESOLVED_FOR_THIS_GATE
EXACT_GITHUB_PLATFORM_ROOT_CAUSE=UNKNOWN_RETAINED
```

No inference is made about the original GitHub platform failure cause.

---

# 9. Final Window 03 verdict

```text
IMPLEMENTATION_AUDIT=PASS
RUNTIME_CAUSAL_CHAIN_AUDIT=PASS
EXACT_ASSET_RUNTIME_BINDING=PASS
FIRE_FEEDBACK_RUNTIME=PASS
OUTCOME_RUNTIME=PASS
RUNTIME_BLOCKER_VERDICT=RESOLVED_BY_FRESH_LOCAL_RUNTIME

PLAYER_UNIT_READABILITY=FAIL
PLAYER_ENVIRONMENT_DELIVERY=FAIL
PLAYER_LAYER_VERDICT=FAIL

REPRODUCTION_AUDIT=FAIL
SPRINT01_CURRENT_VERDICT=NOT_COMPLETE_PLAYER_DELIVERY_CONTRACT_FAILED
SPRINT_PASS=NO
PRODUCT_PRODUCTION_RESUME=NO
```

This is not a gameplay-failure verdict. The gameplay causal slice now works in a fresh runtime. The failure is that the resulting independent reproduction still does not meet the player-facing Stage-5/Stage-6 delivery contract.

---

# 10. Required next route

```text
NEXT_ROUTE=RETURN_TO_02_FOR_IMPLEMENTATION_FIX
```

Window 02 should preserve the already proven causal chain and make only the changes necessary to satisfy the player layer:

1. fix Abrams world-space scale/readability without substituting another unit;
2. preserve the exact sanctioned Abrams and IFV asset identities;
3. remove or strongly reduce world-label occlusion;
4. replace the primitive box/color-block environment with a provenance-recorded real environment/content route;
5. keep `PLAYER INPUT -> COMMAND -> MOVEMENT -> CONTACT -> COMBAT -> VISIBLE FEEDBACK -> OUTCOME` semantics intact;
6. rerun in fresh Godot 4.7.1 runtime;
7. return fresh runtime log, input log, exact-asset binding, fire screenshot, final screenshot and video for Window 03 re-audit.

No redesign of Battle01 or expansion of production scope is authorized by this audit.
