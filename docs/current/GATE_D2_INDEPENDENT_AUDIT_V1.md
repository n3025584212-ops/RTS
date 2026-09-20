# FRONTLINE — INDEPENDENT AUDIT OF GATE D2 (MULTI_FORMATION_SELECTION)

STATUS=PASS_WITH_CONDITION
AUDIT_DATE=2026-09-20
AUDITOR_WINDOW=03_INDEPENDENT_REVIEW (independent audit session, no prior context on this work)
AUDITED_GATE=Gate D2 — MULTI_FORMATION_SELECTION
AUDITED_EVIDENCE=docs/visual_baseline/gate_d2_20260920/EVIDENCE_RECORD.md (+ gate_d2_evidence.json, gate_d2_run.log, 5x 1920x1080 PNG, reference_delta_report.txt, reference_delta_mask_35479014712_vs_35488489417.png)
AUDITED_COMMIT=product/9d026ed (integration) / product/7a4d688 (evidence)
AUDITED_BRANCH=product/frontline-high-fidelity-slice-v1
CONTRACT=main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md (Gate D2 section, opened by main 6e93004)
CI_RUN=35488489417 (Gate D2 integration push, success, 4m18s)
AUDIT_PROTOCOL=Gate C protocol (visual regression / gameplay presence and control validity / proxy leakage / product-slice readability), per GATE_D1_INDEPENDENT_AUDIT_V1.md

## Verdict

PASS_WITH_CONDITION. All five verifiable contract PASS requirements were
independently reproduced and hold: the platoon is real `abrams.glb` product
geometry, click select and drag-box select are demonstrated in fresh media and
counted, the group order routes every vehicle through the validated
`BattleFormation` chain with `accepted=true` x4, and the settled formation
preserves lateral order at frontage 6.000 -> 8.000 m, exactly the declared
invariant `max(8.0 declared pitch, 6.0 pre-order frontage)`. I reproduced the
run myself (exit 0, line-for-line identical log, byte-identical evidence JSON),
re-ran the same-renderer delta comparison from freshly downloaded CI artifacts
(every reported number reproduced; mask byte-identical), and confirmed the
marquee rectangle from first-principles camera projection.

The CONDITION is not about the gate mechanics — it is about an undeclared and
partially mis-declared hull overlap with the Gate D1 hostile that is visible in
every committed frame (details in Conditions and Non-blocking observations).
The gate's own supersession rationale treated interpenetrating vehicles as a
disqualifying defect; one instance of that defect class survives into the
committed evidence, involving the D1 hostile.

## Conditions (must be closed after this audit)

CONDITION-1 (evidence record accuracy). The evidence record's known-limitation
2 states "No settled-state overlap exists (8.0 m spacing, hull 6.4 m wide)".
That is true only for vehicle-vs-vehicle. I computed the hull-footprint
intersection (yaw-170 platoon vehicle vs yaw-150 hostile, both the same ~6.44 x
12.97 m abrams.glb hull, hostile at (8.5, 0.08, 3.0) per
river_town_visual_slice.gd:109 and the CI log):

- At spawn, platoon vehicle 2 (8.5, z 7.0) overlaps the intact hostile footprint
  by ~47 m^2 — about 57% of one hull footprint. This is plainly visible in all
  five committed frames: the red hostile is clipped into the second platoon
  vehicle. It is UNDECLARED — limitation 2 declares only the traversal-path
  crossing.
- At settle (vehicle 2 at z -5.875), the overlap is still ~12.5 m^2 (~15% of a
  hull footprint). "No settled-state overlap exists" is contradicted as written.
- The declared traversal crossing itself is real: vehicle 2's straight path
  crosses z=3.0 at x=8.228, inside the hostile footprint (code and positions
  support it).

CONDITION-2 (fix or explicit acceptance). Resolve the vehicle-2/hostile hull
overlap — move the platoon spawn line, relocate the hostile for the D2
configuration, or record an explicit accepted-limitation entry — before the
next gate builds on this scene state. The WIP was superseded for spawning
"interpenetrating vehicles"; shipping a remaining 57%-of-hull spawn clip in the
committed frames is below the standard this gate set for itself.

## PASS requirements checklist

1. Import/runtime clean (CI recorded) — PASS. `gh run view 35488489417`:
   success, 4m18s; the import step's own error grep (SCRIPT ERROR / Parse Error
   / SHADER ERROR / etc.) did not trip; runtime step emits
   `FRONTLINE_GATE_D2_PLATOON_READY units=4 line_x=[2.5, 8.5, 14.5, 20.5]
   z=7.0 spacing=8.0` plus all four `FRONTLINE_GATE_B_ARMORED_UNIT_READY`
   markers at the correct world positions. Reproduced locally with the same
   result.
2. Real product geometry, no proxies — PASS. The three added vehicles are
   spawned via `spawn("res://assets/visual_slice/abrams.glb", ...)` on the
   mother scene (river_town_visual_slice.gd:125) beside the Gate B foreground
   Abrams; frame inspection shows full PBR detail on all four; no box/cylinder/
   colour-block geometry in the platoon path. The marquee and selection rings
   are CanvasLayer/TorusMesh operator feedback, not debug overlays.
3. Click select and drag-box select demonstrated in fresh media and counted —
   PASS. Frames: click frame shows exactly one selection ring (leftmost
   vehicle); marquee frame shows the cyan marquee mid-drag; box frame shows all
   four rings. JSON: `click_selected_count=1`, `selected_unit_names` length 4,
   `marquee_rect_px` recorded. I independently re-derived the marquee rectangle
   from the camera transform (position (11.5,26,38), target (11.5,0.5,0), fov
   32): the unit-0 screen point projects to ~(531,694), and rect left
   507.39 = 531 - 24 px grow — the rect is genuinely the four unit points grown
   by 24 px, matching `demo_drag_begin`'s construction. Minor note: the JSON has
   no dedicated `box_selected_count` field; the box count is implicit in
   `selected_unit_names` (non-blocking).
4. Group order through the validated chain, all accepted, lateral order and
   frontage per the invariant — PASS. Code: `demo_group_move` ->
   `_formation_destinations` (`pitch = maxf(GROUP_SPACING_WORLD, mean_gap)`,
   river_town_armor_platoon.gd:143) -> `_bind_destination` ->
   `RiverTownArmoredUnit.issue_move_to` -> `formation.issue_move`
   (BattleFormation) -> NavigationService. No parallel movement code exists in
   the platoon script. Numbers re-derived by me from JSON/log:
   - unit count 4; click 0->1; box -> 4; 4x `accepted=true`.
   - minimum advance: per-vehicle displacement sqrt(dx^2+dz^2) = 13.191 /
     12.905 / 12.925 / 13.247 m -> min 12.905 (matches claim), max 13.247
     (JSON 13.249, rounding).
   - frontage: sorted-x mean gap start (20.5-2.5)/3 = 6.000, end
     (23.625-(-0.375))/3 = 8.000; expected = max(8.0, 6.0) = 8.000. The
     invariant genuinely holds and the code implements exactly
     `maxf(declared pitch, current mean gap)` — not just in the assert.
   - lateral order preserved: start order by x equals end order by x; no unit
     crosses another (the log's reversed `dests` listing is display order only;
     measured end positions confirm the preserved mapping).
   - Determinism: my reproduction produced a byte-identical evidence JSON and a
     line-for-line identical run log (exit 0, 52 s on Intel UHD).
5. No regression below the River Town floor beyond the new vehicles and their
   feedback — PASS. I downloaded both CI artifacts (runs 35488489417 and
   35479014712, both reference-view `--capture-frame=1` llvmpipe captures per
   their runtime_metrics.json) and re-ran `tools/compare_render_delta.py`
   myself: exact_match=67.7068%, delta=23.6356% (490,108 px), bbox
   (687,189)-(1919,1079), and all six region numbers match the committed
   report exactly; my regenerated mask is byte-identical to the committed one.
   The mask is vehicle-shaped (three added hulls + shadows); protected regions
   (sky/distant village 0.01%, hero house 0.00%, center village 0.77%) are
   clean. Additive delta, not degradation.
6. Independent audit before formal closure — this document.

## Code review notes (9d026ed / 7a4d688)

- Driver routing is genuine, with one precision point. `demo_click_select`
  calls the same `_click_select` the mouse path runs;
  `demo_drag_begin`/`demo_drag_release` run the same `_box_select`;
  `demo_group_move` runs the same `_formation_destinations` +
  `_bind_destination` + `issue_move_to`. However, `demo_group_move` does NOT
  call `_group_order` itself — it invokes that function's two inner helpers
  directly with a pre-supplied world base, so the screen->ground raycast
  (`_ground_point_under`) is the only part of the mouse order path the driver
  never exercises. The validated movement chain is fully shared; the wrapper
  and its raycast are not covered by this evidence.
- Per-vehicle input is correctly disarmed (`input_enabled=false` in
  `register_unit`; checked first in `_unhandled_input`), so exactly one input
  owner exists — no double-handling between platoon and unit scripts.
- `_click_select` uses a 30 px screen tolerance against the unit centre
  (declared limitation 4) — accurate description, acceptable for a minimum
  gate.
- The `_formation_destinations` sort-along-lateral-axis fix is real and the
  driver would catch a regression (`_order_preserved` sign test over all
  pairs). The superseded WIP JSON in `D:\Agent\rts_captures\gate_d2\
  superseded_wip_1130\` corroborates the documented defect history: 3 units
  (not 4), spawn gaps 3.0/1.3 m (interpenetrating), and a fully reversed end
  order (leftmost unit ending rightmost) — the array-index scramble exactly as
  described. The committed frames are byte-identical to the local capture
  directory, so provenance of the media is consistent.
- Shared-script impact: `river_town_armored_unit.gd` changes are limited to the
  `input_enabled` gate and the selection ring radii (2.35/2.6 -> 4.0/4.3 m).
  This does NOT invalidate archived Gate B/D1 evidence — those artifacts are
  per-commit reproducible and untouched in history. It does mean re-running the
  B/D1 drivers at the current head will render larger rings; that is additive
  operator feedback, and any future same-renderer comparison against pre-D2
  artifacts will show a ring-shaped delta when units are selected. No protected
  subsystem is touched.

## Non-blocking observations

1. Mislabeled diagnostic: `FRONTLINE_GATE_D2_PLATOON_READY ... spacing=8.0`
   (river_town_visual_slice.gd:132-134) prints `GROUP_SPACING_WORLD` — the
   declared ORDER pitch — under the label "spacing", while the actual spawn gap
   is 6.0 m (line_x deltas and `frontage_start_world=6.0` prove it). The line
   contradicts itself; rename the field or print the real mean gap.
2. Selection ring diameter (8.0-8.6 m) exceeds the settled 8.0 m pitch, so
   adjacent selected rings overlap — visible as connected cyan arcs in
   `gate_d2_box_selected.png`. Cosmetic; consider ring radius < pitch/2 or
   accept.
3. The evidence record's same-renderer section says the delta mask includes
   "the enlarged selection ring". Impossible: the reference captures are taken
   at frame 1 with nothing selected, so no ring exists in either artifact. The
   delta is the three vehicles and their shadows only. Prose correction needed.
4. The record's inline order narrative says vehicles settle at "z -6.0" /
   "x -0.5/7.5/15.5/23.5"; measured settle is z -5.875 / x -0.375..23.625 (a
   uniform ~0.125 m hold offset). The record's own numeric account states
   z=-5.875 correctly; the narrative and JSON should agree.
5. Requirement 3 asks for the box-select count "in the evidence JSON"; there is
   no explicit `box_selected_count` key (only the 4-entry
   `selected_unit_names`). Add the key in the next driver revision.
6. `WARNING: 7 RIDs of type "Texture" were leaked` on exit — pre-existing
   cosmetic engine-side warning, not introduced by this gate.
7. Only one group order is demonstrated; queues, mixed arms, selection
   persistence are out of scope (declared). Real mouse input is not exercised
   (declared; the human-playtest checkpoint remains the place for it).

## Recommended routing

Gate D2 mechanics are sound and independently reproduced; route as
PASS_WITH_CONDITION. Window 00 should: (1) require the CONDITION-1 evidence
record correction and the CONDITION-2 overlap fix-or-acceptance as a small
follow-up commit on the product branch before opening Gate D3 or the human
playtest checkpoint; (2) fold the mislabeled `spacing=` diagnostic and the
missing `box_selected_count` key into that same follow-up. CI success remains
technical reproduction, not visual acceptance — the frames' hostile clipping
makes a human eyeball pass on the next gate's media mandatory.
