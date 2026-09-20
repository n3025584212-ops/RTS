# Gate D2 Evidence Record — MULTI_FORMATION_SELECTION — 2026-09-20

STATUS=EVIDENCE_COMPLETE_PENDING_AUDIT
PARENT=Gate D1 (MINIMUM_COMBAT_CHAIN, PASS) — D2 extends the integrated slice from one controllable vehicle to a platoon
BRANCH=product/frontline-high-fidelity-slice-v1
ENGINE=Godot 4.7.1-stable official, Forward+, Vulkan 1.4.323 (Intel UHD Graphics), 1920x1080, capture_view=gate_d2

## What was integrated

- `scripts/production/river_town_armor_platoon.gd` (new) — platoon-level input for the River Town mother
  scene: single-click select, drag-box select with an on-screen marquee, and formation-preserving group
  orders. Per-vehicle input is disabled through `RiverTownArmoredUnit.input_enabled` so one owner handles
  the mouse. Selection and ordering run through the same validated chain the vehicles already use
  (`BattleFormation.set_selected` / `issue_move` -> `NavigationService`); no parallel movement code.
- `scripts/production/river_town_visual_slice.gd` (extended) — spawns three more real `abrams.glb`
  vehicles as a line abreast beside the Gate B foreground Abrams (hull is 6.4 x 13.0 m world, long axis Z;
  spawn pitch 6.0 m, declared order pitch 8.0 m) and adds the `gate_d2` capture view.
- `scripts/production/river_town_armored_unit.gd` (extended) — `input_enabled` gate; selection ring
  enlarged to inner 4.0 / outer 4.3 m so it clears the 6.4 m-wide hull and reads as operator feedback
  from a 3/4 view (a hull-sized ring is completely hidden under the vehicle).
- `tools/gate_d2_capture.gd` (new, committed) — evidence driver; every stage asserts before advancing
  (platoon size, click count, marquee active/cleared, box count, formation invariants) and the run exits
  non-zero on failure.

## Evidence run (this directory: 5 frames + `gate_d2_evidence.json` + `gate_d2_run.log`)

- `FRONTLINE_GATE_D2_PLATOON_READY units=4 line_x=[2.5, 8.5, 14.5, 20.5] z=7.0 spacing=8.0`
- Click path: `FRONTLINE_GATE_D2_CLICK_SELECT selected=0` -> `GATE_D2_EVIDENCE_CLICK selected=1`
- Drag-box path phase 1: `FRONTLINE_GATE_D2_DRAG_BEGIN rect=[P: (507.4, 668.4), S: (904.9, 54.2)] swept=4`
- Drag-box path phase 2: `FRONTLINE_GATE_D2_DRAG_RELEASE selected=4`
- Group order: 4 x `FRONTLINE_GATE_B_ORDER_ISSUED ... accepted=true` (sim (275,320)->(245,190),
  (335,320)->(325,190), (395,320)->(405,190), (455,320)->(485,190) — i.e. world x 2.5/8.5/14.5/20.5 ->
  -0.5/7.5/15.5/23.5 at z -6.0, each vehicle keeping its own lateral slot)
- Settlement: `GATE_D2_EVIDENCE_ASSERT minimum_advance=12.905 frontage_start=6.000 frontage_end=8.000
  expected=8.000 order_preserved=true frontage_preserved=true`
- Media: `gate_d2_before_selection.png` (line at rest, nothing selected),
  `gate_d2_click_selected.png` (one vehicle selected), `gate_d2_drag_marquee.png` (marquee drawn across
  the platoon mid-drag), `gate_d2_box_selected.png` (four vehicles selected),
  `gate_d2_group_moved.png` (the line advanced ~13 m, opened 6.0 -> 8.0 m, still in order).

## Numeric account the auditor can re-derive

- Platoon: 4 real `abrams.glb` vehicles, all from `tank.tres` (role=TANK, hp=280, move_speed=85,
  attack_range=300). No proxies, no colour blocks.
- Selection: 1 click -> 1 selected; one marquee rect (905 x 54 px, spanning all four vehicles) ->
  4 selected.
- Group order: destination base = platoon centre (11.5, 0, -6); the algorithm sorts the selected units
  along the lateral axis and re-slots them at `pitch = max(8.0, current mean gap)`, so the settled
  frontage must equal `max(8.0, 6.0) = 8.0`. Measured: 6.000 -> 8.000 (tolerance 0.5).
- Lateral order is preserved (no unit crosses another); minimum per-vehicle advance 12.905 m; all four
  end HOLD at z = -5.875 with 8.0 m spacing.

## Defects found and fixed during this gate (worth auditing)

1. The WIP platoon code assigned destination slots by array index, so a group order sent the leftmost
   vehicle to the rightmost slot and scrambled the formation. Replaced by sort-along-lateral-axis then
   re-slot in that order. The driver now asserts order preservation and fails the run if it regresses.
2. The WIP spawn layout put four 13 m vehicles 2.2 m apart — the vehicles interpenetrated and the capture
   read as one mass. Spawn geometry is now measured (probe: hull AABB 6.44 x 6.96 x 12.97 m) and spaced.
3. A snapshot taken in the same frame as a state change records the *previous* rendered frame, so the
   WIP capture showed neither marquee nor selection rings. The driver now changes state and snaps
   three frames apart.

## Run-to-run reproducibility

Two local runs of the committed driver on this workstation (2026-09-20) produced a byte-identical
`gate_d2_evidence.json` and identical assertion values: `minimum_advance=12.905`,
`frontage_start=6.000`, `frontage_end=8.000`, `expected=8.000`, `order_preserved=true`,
`frontage_preserved=true`, and identical per-vehicle end positions.

Frames are not byte-identical, and the evidence does not claim they are: `gate_d2_before_selection.png`
matched to 99.9834% exact / 0.0014% beyond tolerance 8 (30 px of 2,073,600). `gate_d2_group_moved.png`
differed over the vehicle band (8.04% of the frame beyond tolerance 8, mean absolute delta 1.87/255,
delta confined to the vehicles: rows 250-560 mean 12.17) while the region outside the vehicles was
identical (upper band 0.01%). Cause: the per-frame heading lerp is visual-only and the transient
order-feedback markers expire on a wall-clock timer, so which frame the settle condition is detected on
changes those pixels. Positions, counts and formation numbers are unaffected.

Reproduce with:
`python3 tools/compare_render_delta.py OLD.png NEW.png --tolerance 8 --mask mask.png`

## Same-renderer CI comparison (no-regression evidence)

Protocol as established at Gate C/D1: compare the current gate's CI artifact against the previous
gate's artifact, both llvmpipe reference captures at `--capture-frame=1`.

- run 35488489417 (this gate, product commit 9d026ed) vs run 35479014712 (Gate D1, aedabe0)
- `exact_match=67.7068%`; delta beyond tolerance 8 = `23.6356%` (490,108 px); bbox (687,189)-(1919,1079)
- region report (`reference_delta_report.txt`, mask `reference_delta_mask_35479014712_vs_35488489417.png`):
  sky_and_distant_village 0.01%, hero_house 0.00%, center_village 0.77%,
  vehicle_band 42.92%, far_right_field 65.06%, foreground_ground 26.47%
- The mask shows the delta is vehicle-shaped: the three added vehicles, their shadows and the enlarged
  selection ring — exactly the geometry this gate requires. The protected environment (terrain, hero
  house, distant village, lighting, atmosphere) is unchanged to within 0.77% and no change spreads into
  the scene. This is an additive delta, not degradation.
- CI run 35488489417: success, 4m18s. CI-side runtime log reproduces the platoon markers
  (`FRONTLINE_GATE_D2_PLATOON_READY units=4 line_x=[2.5, 8.5, 14.5, 20.5] z=7.0 spacing=8.0`) and the
  import step is clean (no SCRIPT/Parse/SHADER errors).

## Known limitations (for the auditor)

1. The driver supplies the drag geometry (the marquee rectangle) programmatically and then runs the same
   `_box_select` / `_click_select` / `issue_move_to` entry points the mouse runs. Real mouse input and a
   human operator are NOT exercised by this evidence — that is the separate human-playtest checkpoint.
2. There is still no collision or avoidance system (declared since Gate B). `vehicle_blocked=0` in the
   navigation service, and one platoon vehicle's straight-line path crosses the Gate D1 hostile's
   footprint at (8.5, 0.08, 3.0). No settled-state overlap exists (8.0 m spacing, hull 6.4 m wide), but no
   traversal frame is offered as evidence, and binding static vehicles as navigation obstacles is future work.
3. Only one group order is demonstrated; multi-order queues, mixed-arms platoons, and selection
   persistence across orders are out of scope for this minimum gate.
4. The click-select path uses a 30 px screen tolerance against the vehicle centre; it is not a hull-picking
   test, so clicking the barrel of a vehicle that is nearly edge-on may miss. Acceptable for a minimum gate.
5. `tools/d2_probe.gd` (layout probe used to measure the hull and terrain) is a development tool and is
   NOT committed; the measurements it produced are recorded in this document.
