# FRONTLINE — INDEPENDENT AUDIT OF GATE D1 (MINIMUM_COMBAT_CHAIN)

STATUS=PASS
AUDIT_DATE=2026-09-20
AUDITOR_WINDOW=03_INDEPENDENT_REVIEW (performed by ZCode agent session, 2026-09-20)
AUDITED_GATE=Gate D1 — MINIMUM_COMBAT_CHAIN
AUDITED_EVIDENCE=docs/visual_baseline/gate_d1_20260920/EVIDENCE_RECORD.md
AUDITED_COMMIT=product/aedabe0
AUDITED_BRANCH=product/frontline-high-fidelity-slice-v1
CONTRACT=main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md (Gate D1 section, opened by main 142be6f)
CI_RUN=35479014712 (Gate D1 integration push, success, 6m45s)
AUDIT_PROTOCOL=Gate C protocol (visual regression / gameplay presence and control validity / proxy leakage / product-slice readability)

## Verdict

PASS, no blocking conditions. All contract PASS requirements are satisfied,
the numeric chain (ammo, shots, damage, hp) is matrix-consistent and
reproducible from a committed driver, the destruction state is visible in
fresh media, and there is no regression below the River Town floor. The Gate
C provenance lesson from Gate B was absorbed: the evidence driver is
committed in the same integration commit as the feature.

## PASS requirements checklist

1. Import/runtime clean — PASS. CI run 35479014712 (triggered by the aedabe0
   push touching river_town_visual_slice.gd): import and runtime steps clean,
   no SCRIPT/Parse/SHADER errors; log line `FRONTLINE_GATE_D1_TARGET_READY
   role=TANK hp=280 sim=(335.0, 280.0) world=(8.5, 0.07997, 3.0)` independently
   reproduced in CI.
2. Hostile instantiated as real PBR asset — PASS. Second real `abrams.glb`
   spawned via the mother scene with the same armor-shader treatment, red-
   shifted through `paint_color` (tint 1.0/0.42/0.38); frame inspection shows
   full texture detail (camouflage mottling through the red tint, rust,
   launchers, antennas) — no color-block proxy.
3. Fire cycle demonstrated in fresh media with matrix-consistent damage and
   ammo accounting — PASS. Numeric audit:
   - tank.tres: attack_damage=45, attack_range=300, fire_interval=1.50,
     ammo_capacity=16, max_hp=280, role=TANK (HEAVY_ARMOR).
   - Order range: 7.21 m world = 72.1 sim, inside the 300 sim range.
   - Ammo 16 -> 9 = 7 shots; 7 x 45 x 1.0 (TANK vs TANK multiplier) = 315 >= 280 hp.
   - engaging frame at 145 hp = 280 - 3x45, matching the driver's <=60%
     stage trigger and the declared ~48% char.
   - json written at runtime by the driver (with trailing newline — prior
     finding addressed).
4. Destruction state visible — PASS. Three-stage progression verified by
   frame inspection: intact red -> partial char (engaging) -> full char
   (destroyed), driven by health_changed/died through the validated matrix.
5. No regression below the River Town floor — PASS. Same-renderer CI artifact
   comparison (run 35479014712 vs run 35464759495, both llvmpipe reference
   view): 5.8% pixels differ, bbox (456,217)-(1865,944). Frame inspection
   confirms the delta region is exactly the newly added hostile vehicle and
   its ground shadow — an addition required by this gate, not a degradation;
   terrain, architecture, lighting, atmosphere unchanged.
6. Independent audit before formal closure — this document.

## Code review notes (aedabe0)

- battle01 combat classes untouched: `set_combat_target` -> `_update_combat`
  (hold-fire veto, can_attack/ammo, target validity, range, optional LOS,
  cooldown, ammo decrement, attack_fired signal, take_damage) is the existing
  validated chain; the integration only binds it (`demo_issue_attack` ->
  `set_combat_target` on the BLUE formation; hidden RED formation receives
  damage through the same matrix).
- `river_town_hostile_target.gd` clones the player vehicle's armor-shader
  material pipeline surface-by-surface (albedo/normal/roughness/metal/ao with
  channel mapping and surface roles) — consistent treatment, not a tint hack.
- Driver `tools/gate_d1_capture.gd` is a state machine (before -> <=60% hp ->
  destroyed) with explicit FAIL paths and a 4000-frame timeout; it writes the
  evidence JSON at runtime, so the media/json/log triplet is reproducible
  from the library. This closes the provenance-gap class found in Gate B.

## Non-blocking observations

1. The raw local runtime log of the evidence run is not archived in the
   evidence directory (Gate B closure archived gate_b_run.log). The committed
   driver makes the run reproducible, so provenance holds; recommend archiving
   the log alongside the JSON in future gates for uniformity.
2. Driver writes captures to the absolute path `D:/Agent/rts_captures/gate_d1`
   (line 17) — fine for this workstation, not portable; consider
   `user://` or a repo-relative path in the next driver.
3. Tracer lifetime 0.12 s vs frame-rate-dependent capture timing: the tracer
   may fall between frames (declared limitation; fire progression is carried
   by paint charring and log lines, which the frames do show).
4. The two vehicles park ~7 m apart with no collision system (declared
   limitation, minimum-gate scope).
5. `demo_issue_attack` selects the unit, so the cyan selection ring is visible
   in the engaging/destroyed frames — RTS-idiomatic operator feedback,
   consistent with the Gate B capture; not a debug overlay.

## Recommended routing

Gate D1 is complete. Window 00 may set Gate D1 STATUS=GATE_D1_PASS in the
contract and define the next gate (D2 multi-formation selection or a human
playtest checkpoint per the current routing note).
