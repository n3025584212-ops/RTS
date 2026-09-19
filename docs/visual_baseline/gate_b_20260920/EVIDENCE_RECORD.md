# Gate B Evidence Record — MINIMUM_ARMORED_UNIT_INTEGRATION — 2026-09-20

STATUS=EVIDENCE_COMPLETE_PENDING_GATE_C
GATE_CONTRACT=main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md (authoritative)
BRANCH=product/frontline-high-fidelity-slice-v1
INTEGRATION_COMMIT=24ad352 + this docs commit
CAPTURE_VIEW=gate_b (new additive camera; reference/hero/ground unchanged)
ENGINE=Godot 4.7.1-stable official, Forward+, Vulkan 1.4.323 (Intel UHD Graphics), 1920x1080

## What was integrated

- `scripts/production/river_town_armored_unit.gd` — binds the validated `BattleFormation` control chain (selection -> `issue_move` -> path follow -> movement) to the real `assets/visual_slice/abrams.glb` PBR mesh. The 2D formation visuals are hidden; the 3D mesh is driven from the sim position with terrain-height binding and travel-direction heading. Minimal mouse input (LMB select / RMB order) plus the programmatic `demo_issue_move` entry point used by the evidence run — both go through the same validated chain.
- `scripts/production/river_town_sim_navigation.gd` — `BattleNavigation` subclass configuring the validated core `NavigationService` with River Town sim parameters (open vehicle grid, 500x500 sim / 0.1 scale). Greybox route/terrain tables are not used.
- `scripts/production/river_town_visual_slice.gd` — additive `call_deferred("_integrate_gate_b_armored_unit")` hook + `gate_b` capture view. Mother scene pipeline untouched.

## PASS evidence checklist (contract items 1-7)

1. Import/runtime without fatal error — headless editor import exit 0, zero SCRIPT/Parse/SHADER errors; capture run exit 0.
2. Unit instantiated — `FRONTLINE_GATE_B_ARMORED_UNIT_READY role=TANK hp=280 speed=85 sim=(275,320) world=(2.5,0.03,7)`.
3. Control/movement chain demonstrated — `FRONTLINE_GATE_B_ORDER_ISSUED sim_from=(275,320) sim_to=(300,240) accepted=true`; displacement logged `(2.5,7) -> (5.125,-0.875)`; final order HOLD, unit selected; selection ring visible in media.
4. Fresh 1920x1080 media — `gate_b_before_order.png`, `gate_b_mid_move_1.png`, `gate_b_mid_move_2.png`, `gate_b_arrived.png`, `gate_b_evidence.json` (this directory).
5. Visual comparison vs retained floor — terrain, hero house, village, vegetation, lighting, water, atmosphere pixel-comparable to `docs/visual_baseline/river_town_sole_20260920/`; the only delta is the unit's position/rotation and selection ring. No regression.
6. No proxy substitution — real PBR Abrams mesh, no box/cylinder/color-block proxy at any point; protected subsystems untouched (integration is additive).
7. Branch/commit/workflow evidence — integration commit `24ad352`, docs commit (this one); the push touches `river_town_visual_slice.gd`, triggering the `FRONTLINE River Town Visual Slice` CI workflow as independent CI reproduction of the capture protocol.

## Technical note for the Gate C auditor

The Abrams was historically spawned statically at a position OUTSIDE the `hero` camera frustum (the historical hero view frames the foreground house — `ForegroundHeroHouseRuined` — not the vehicle), which is why earlier hero captures never showed it. The `gate_b` capture view was added to frame the unit, the house and the village together. No existing camera was moved.

## Restoration / reproduction

Run: `godot --path . --rendering-method forward_plus --resolution 1920x1080 res://scenes/production/RiverTownVisualSlice.tscn -- --view=gate_b` — the unit is selected by LMB near the tank and ordered with RMB; the evidence run's programmatic path is `demo_issue_move`.
