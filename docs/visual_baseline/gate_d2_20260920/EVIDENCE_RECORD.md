# Gate D2 Evidence Record — MULTI_FORMATION_SELECTION — 2026-09-20

STATUS=EVIDENCE_COMPLETE_PENDING_REAUDIT (revision 2 — closes the two conditions of GATE_D2_INDEPENDENT_AUDIT_V1.md)
PARENT=Gate D1 (MINIMUM_COMBAT_CHAIN, PASS) — D2 extends the integrated slice from one controllable vehicle to a platoon
BRANCH=product/frontline-high-fidelity-slice-v1
ENGINE=Godot 4.7.1-stable official, Forward+, Vulkan 1.4.323 (Intel UHD Graphics), 1920x1080, capture_view=gate_d2
SUPERSEDES=product 9d026ed (evidence) / 7a4d688 (evidence addendum) — revision 1, audited PASS_WITH_CONDITION

## Why revision 2 exists

The Gate D2 independent audit (docs/current/GATE_D2_INDEPENDENT_AUDIT_V1.md) returned
PASS_WITH_CONDITION. It confirmed the gate mechanics but found that revision 1 shipped a real defect
and described it wrongly:

- CONDITION-1: the record claimed "No settled-state overlap exists (8.0 m spacing, hull 6.4 m wide)".
  Measured independently by the auditor: the deployment row's second vehicle spawned at (8.5, 7.0),
  4 m from the Gate D1 hostile at (8.5, 0.08, 3.0); both hulls are ~6.44 x 12.97 m, and the overlap was
  ~47-58 m^2 of hull footprint at spawn and still ~12.5 m^2 at settle. The clipping is visible in every
  revision-1 frame: the red hull is cut through the second platoon vehicle. The declared traversal-path
  crossing was real but the record declared only that.
- CONDITION-2: fix or explicitly accept the overlap before the next gate builds on this scene state.

Both conditions are closed in this revision by changing the integration, not the wording.

## What revision 2 changed

- **Deployment no longer overlaps the D1 hostile.** The three added vehicles deploy north of the village
  road at z -12.0 (line_x 6.0/14.0/22.0) instead of beside the hostile at z 7.0. Placement rules now
  encoded in `river_town_armor_platoon.gd`: a hull must sit east of x 15.7, north of z -9.7 or south of
  z 15.5 to clear the hostile's 9.05 x 12.23 m footprint, and the vehicle navigation grid is
  500 x 500 sim units = world +-25 m, so nothing may sit or path outside +-24 m.
- **No vehicle's path crosses the hostile either.** The group order advances everyone north; the Gate B
  Abrams (x 2.5) stays west of the hostile's x range (>= 3.43) for its whole path, and the deployed row
  starts north of the hostile's z range and moves further north.
- **Group slots are centred on the ordered point**, not on the formation's own lateral midpoint. The old
  centring offset the whole row by however far the group sat off-centre from the click, which pushed the
  outer vehicles past the navigation map edge; those vehicles then pathed to the boundary and reported
  HOLD short of their slot (observed as a 27-minute timeout with three vehicles stuck at 4-5 m).
- **The group order now runs through the mouse wrapper** (`demo_group_order_at_world` unprojects the
  requested world point to a screen point and calls `_group_order`, so the screen->ground raycast is
  exercised). The audit's code-review note that the raycast was the only uncovered part of the mouse path
  is closed: achieved base (11.0, 0.0305, -19.4645) vs requested (11.0, 0.0, -19.5), 0.036 m apart.
- **The driver freezes live input** for the driven stages. A 27-minute run accumulated 11 stray OS mouse
  events that re-selected and cleared the selection mid-run; evidence integrity now does not depend on
  where the operator's cursor is.
- **The driver asserts navigation bounds** on every settled vehicle and prints a settle watchdog
  (`GATE_D2_SETTLE_WATCH frame=<n> <unit>:<order>@<metres moved>`) so a stuck order is diagnosable from
  the archived log instead of only as a timeout.
- Mislabeled diagnostic fixed: the ready line printed the order pitch under the label `spacing` while the
  actual deployment frontage was 6.0 m. It now reports `deployment_frontage=<measured>` and
  `order_pitch_floor=<declared>`. The evidence JSON gained `box_selected_count` (the audit's requirement-3
  note) and `group_base_requested` / `group_base_achieved`.

## Integration (unchanged from revision 1 in substance)

- `scripts/production/river_town_armor_platoon.gd` — platoon input owner: single-click select, drag-box
  select with an on-screen marquee, formation-preserving group orders. Selection and movement call the
  existing `BattleFormation` chain (`set_selected` / `issue_move` -> `NavigationService`); no parallel
  movement code.
- `scripts/production/river_town_visual_slice.gd` — spawns the three extra real `abrams.glb` vehicles and
  adds the `gate_d2` capture view.
- `scripts/production/river_town_armored_unit.gd` — `input_enabled` gate; selection ring enlarged to
  inner 4.0 / outer 4.3 m so it clears the 6.4 m-wide hull.
- `tools/gate_d2_capture.gd` — evidence driver; every stage asserts before advancing and the run exits
  non-zero on failure.

## Evidence run (this directory: 5 frames + `gate_d2_evidence.json` + `gate_d2_run.log`)

- `FRONTLINE_GATE_D2_PLATOON_READY units=4 line_x=[2.5, 6.0, 14.0, 22.0] z=-12.0 deployment_frontage=6.500
  order_pitch_floor=8.0`
- Click path: `FRONTLINE_GATE_D2_CLICK_SELECT selected=0` -> `GATE_D2_EVIDENCE_CLICK selected=1`
- Drag-box path: `FRONTLINE_GATE_D2_DRAG_BEGIN ... swept=4` -> `FRONTLINE_GATE_D2_DRAG_RELEASE selected=4`
- Group order: 4 x `FRONTLINE_GATE_B_ORDER_ISSUED ... accepted=true` (sim_to x = 240/320/400/480 at
  sim y 55.36, i.e. one uniform row at z -19.38), routed through
  `FRONTLINE_GATE_D2_GROUP_ORDER_AT_WORLD requested=(11.0, 0.0, -19.5)`
- Settlement: `GATE_D2_EVIDENCE_ASSERT minimum_advance=7.460 frontage_start=6.500 frontage_end=8.000
  expected=8.000 order_preserved=true frontage_preserved=true`
- Media: `gate_d2_before_selection.png` (deployed row, nothing selected), `gate_d2_click_selected.png`
  (one vehicle), `gate_d2_drag_marquee.png` (marquee over the platoon), `gate_d2_box_selected.png`
  (four selected), `gate_d2_group_moved.png` (the row advanced onto the north road, still in order).

## Numeric account the auditor can re-derive

- Platoon: 4 real `abrams.glb` vehicles, all from `tank.tres` (role=TANK, hp=280, move_speed=85,
  attack_range=300). No proxies, no colour blocks.
- Selection: click -> 1 selected; one marquee rect (643 x 504 px) -> 4 selected (`box_selected_count=4`).
- Deployment: Gate B Abrams at (2.5, 7.0); added vehicles at (6.0, -12.0), (14.0, -12.0), (22.0, -12.0)
  — 8 m apart, hulls 6.44 m wide, so 1.5 m of hull clearance between them, and >= 2.3 m of hull clearance
  from the D1 hostile for every added vehicle (the added hulls sit at z -18.5..-5.5, the hostile's
  footprint ends at z -3.20).
- Group order: requested base (11.0, 0, -19.5); achieved base (11.0, 0.0305, -19.4645).
  `pitch = max(8.0, 6.5) = 8.0`, so the settled frontage must be 8.0: measured 6.500 -> 8.000.
  Settled positions: x -0.875 / 7.125 / 15.125 / 23.125 at z -19.375 — 8.0 m apart, in the original
  left-to-right order, every vehicle inside the navigation map (|x| <= 23.125, |z| = 19.375 < 24).
  Minimum per-vehicle advance 7.460 m, maximum 26.590 m (the Gate B Abrams drives furthest), all HOLD.

## Run-to-run reproducibility

Two local runs of the committed driver produce identical assertion values and an identical set of
settled positions (`minimum_advance=7.460`, `frontage 6.500 -> 8.000`, order preserved). Frames are not
byte-identical and the record does not claim they are: the scene animates smoke and temporal history, so
which frame the settle condition is detected on changes those pixels. The Gate D2 revision-1 pair is
reported here for continuity: `gate_d2_before_selection.png` matched to 99.9834% exact, while the settled
frame differed over the vehicle band only (positions, counts and formation numbers identical).

Reproduce with:
`python3 tools/compare_render_delta.py OLD.png NEW.png --tolerance 8 --mask mask.png`

## Same-renderer CI comparison (no-regression evidence)

Protocol as established at Gate C/D1: compare the current gate's CI artifact against the previous gate's
artifact, both llvmpipe reference captures at `--capture-frame=1`.

Revision-1 evidence (kept for the audit trail): run 35488489417 vs run 35479014712 —
`exact_match=67.7068%`, delta 23.6356% (490,108 px), bbox (687,189)-(1919,1079); region report
sky_and_distant_village 0.01%, hero_house 0.00%, center_village 0.77%, vehicle_band 42.92%,
far_right_field 65.06%, foreground_ground 26.47%. The mask (`reference_delta_mask_35479014712_vs_35488489417.png`)
shows the delta is vehicle-shaped only — the added vehicles, their shadows and the enlarged selection
ring. Correction against the audit's note 3: the reference captures are taken at frame 1 with nothing
selected, so the ring cannot appear in that comparison; the delta is the added vehicles and their
shadows. Revision 2 also moves the deployed row further from the reference camera (z -12.0 across the
north road instead of a row beside the street), and its CI comparison is materially smaller: run
35492164998 vs run 35479014712 gives exact_match=93.6453%, delta 4.5635% (94,628 px), bbox
(858,249)-(1919,569); region report sky_and_distant_village 0.00%, hero_house 0.00%,
foreground_ground 0.00%, center_village 5.30%, vehicle_band 7.91%, far_right_field 32.05%
(`reference_delta_report_r2_35479014712_vs_35492164998.txt`, mask
`reference_delta_mask_r2_35479014712_vs_35492164998.png`; CI runtime log archived as
`ci_runtime_log_r2_35492164998.log`). The delta is entirely the added vehicles and their shadows
in the field they now occupy; the protected environment is pixel-identical (0.00%).

## Defects found and fixed across this gate (worth auditing)

1. Group order assigned slots by array index, sending the leftmost vehicle to the rightmost slot and
   scrambling the formation (fixed: sort along the lateral axis, re-slot in that order).
2. Deployment put four 13 m vehicles 2.2 m apart — hulls interpenetrated (fixed: measured geometry, 8 m
   spacing, placement rules above).
3. Snapshots taken in the same frame as a state change recorded the *previous* rendered frame, so the
   marquee and selection rings were absent from the media (fixed: change state, snap 3 frames later).
4. Deployment row overlapped the D1 hostile by ~47-58 m^2 of hull footprint and the record denied it
   (fixed: redeployed north; record corrected — this is the audit's CONDITION-1/2).
5. Deployment extended past the navigation map (x 34 > 25 m), so the pathfinder dragged a vehicle to the
   map edge and the run timed out (fixed: placement rules + navigation-bound assertion).
6. Group slots were centred on the formation's own lateral midpoint rather than the ordered point, which
   pushed the outer vehicles past the map edge and reported them settled short of their slots
   (fixed: centre on the ordered point).
7. Stray OS mouse events during a long run re-selected and cleared the selection (fixed: the driver
   disables live input for the driven stages).

## Known limitations (for the auditor)

1. The driver supplies the drag geometry (the marquee rectangle) programmatically and then runs the same
   `_box_select` / `_click_select` / `_group_order` entry points the mouse runs, including the screen
   -> ground raycast for the order. Real operator mouse input (motion, button hold/release, click
   timing) is still NOT exercised — that is the separate human-playtest checkpoint.
2. The Gate B Abrams at (2.5, 7.0) and the D1 hostile at (8.5, 0.08, 3.0) sit 7.2 m apart, their mesh
   AABBs overlap by ~2 m in x (the AABB includes the forward gun and antennas). This pair is unchanged
   from Gate D1, which passed audit after frame inspection; no added vehicle is within 9 m of the
   hostile, and no settled formation overlap remains in this gate.
3. There is still no collision or avoidance system: `vehicle_blocked=0` in the navigation service, so
   nothing prevents a path through a static vehicle. In this layout no path crosses the hostile, but
   binding static vehicles as navigation obstacles remains future work.
4. Only one group order is demonstrated; order queues, mixed-arms platoons and selection persistence
   across orders are out of scope for this minimum gate.
5. Selection rings are 8.6 m across while the settled pitch is 8.0 m, so adjacent selected rings touch
   and read as a chain in `gate_d2_box_selected.png` / `gate_d2_group_moved.png`. Cosmetic, accepted:
   the ring has to clear the 6.4 m hull to be visible at all from a 3/4 view.
6. The click-select tolerance is 30 px against the vehicle centre (not a hull pick), so a click on a
   nearly edge-on vehicle may miss.
7. `WARNING: 7 RIDs of type "Texture" were leaked` on exit is a pre-existing engine-side warning, not
   introduced by this gate.
