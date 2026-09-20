# FRONTLINE — GATE C INDEPENDENT AUDIT OF GATE B (MINIMUM_ARMORED_UNIT_INTEGRATION)

STATUS=PASS_WITH_ONE_CONDITION
AUDIT_DATE=2026-09-20
AUDITOR_WINDOW=03_INDEPENDENT_REVIEW (performed by ZCode agent session, 2026-09-20)
AUDITED_GATE=Gate B — MINIMUM_ARMORED_UNIT_INTEGRATION
AUDITED_EVIDENCE=docs/visual_baseline/gate_b_20260920/EVIDENCE_RECORD.md
AUDITED_COMMIT=24ad352 (integration) + 52b0724 (evidence docs)
AUDITED_BRANCH=product/frontline-high-fidelity-slice-v1
CONTRACT=main::docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md (authoritative)
CI_REFERENCE_RUN=35464759495 (Gate B integration push, success, 6m43s)
CI_BASELINE_RUN=35325714573 (pre-integration Gate A run #7, success)

## Verdict

PASS with one condition. All seven contract evidence items are satisfied; the
mother scene shows zero visual regression (hard evidence below); no proxy
leakage; the capture reads as a real RTS product slice, not a test scene.
One evidence-management gap must be closed before Gate C is formally closed.

## Contract evidence checklist (7/7 satisfied)

1. Import/runtime without fatal error — PASS. CI import step reverse-grep
   assertion clean (no SCRIPT/Parse/SHADER errors); runtime step clean.
2. Armored unit instantiated — PASS. CI log line independently reproduces the
   recorded value: `FRONTLINE_GATE_B_ARMORED_UNIT_READY role=TANK hp=280
   speed=85 sim=(275.0, 320.0) world=(2.5, 0.030538, 7.0)`.
3. Control/movement chain demonstrated in fresh runtime media — PASS (media).
   The four 1920x1080 frames show the unit at (2.5, 7.0) before order, then at
   the ordered target (5.0, -1.0) vicinity with changed heading and the cyan
   selection ring visible; gate_b_evidence.json records arrived position,
   HOLD, selected=true. See the gap below for the log-line provenance.
4. Fresh 1920x1080 media — PASS. All four PNGs verified 1920x1080 by direct
   inspection; evidence JSON present.
5. Visual comparison / no regression — PASS (hard evidence). Artifact PNG
   `artifacts/visual_reset/river_town_actual_1920x1080.png` from the
   pre-integration CI run 35325714573 and from the Gate B run 35464759495
   were downloaded and compared pixel-by-pixel: diff bbox = None, max channel
   diff = 0, changed pixels = 0. The integration does not regress the mother
   scene render. Note: comparing either CI render against the local
   GPU-rendered baseline shows ~51% pixel deviation because CI renders on
   llvmpipe software rasterization (renderer difference, not a scene change);
   the same-renderer before/after comparison above is the authoritative
   regression check.
6. No proxy substitution — PASS. Integration binds the real
   `M1A2_SEPv3_dannzjs_CC_BY_4` PBR asset; frames show the full camouflage
   Abrams with tracks, smoke launchers, antenna; no box/cylinder/color-block
   battlefield. The selection ring and the 1.4 s command marker are operator
   feedback UI in the RTS idiom, not battlefield proxies.
7. Branch/commit/workflow evidence — PASS. Remote branch head = 52b0724
   (contains 24ad352); integration push triggered the `FRONTLINE River Town
   Visual Slice` workflow, run 35464759495, conclusion success.

## Code review notes (24ad352)

- Integration is genuinely additive: two new scripts plus one deferred hook
  and one additional capture view in the mother-scene script; terrain,
  material, lighting and existing camera paths untouched.
- The chain reuses the validated classes (`BattleFormation`,
  `BattleNavigation` subclass, core `NavigationService`) rather than
  reimplementing movement; 2D formation visuals are hidden via modulate.
- `RiverTownSimNavigation._ready()` intentionally skips the greybox route
  tables and configures an open 500x500 / 2.5 m vehicle grid; terrain-obstacle
  binding is correctly deferred as future work beyond this gate.
- Debug overlay suppression (`_draw()` pass) and the additive gate_b camera
  comply with the player-facing capture constraints.

## Condition to close before Gate C is marked closed

EVIDENCE_PROVENANCE_GAP: `demo_issue_move` has no caller anywhere in the
repository; the CI workflow only runs `--capture --capture-frame=1` (baseline
single frame) and does not exercise the gate_b sequence. Therefore the
`FRONTLINE_GATE_B_ORDER_ISSUED ... accepted=true`, displacement, and
final-order HOLD log lines quoted in EVIDENCE_RECORD.md are not reproducible
from anything in the library — no committed driver script, no archived local
log, no generator for gate_b_evidence.json. The media and the JSON's terrain
signature indicate a genuine run, but the provenance chain is broken.

Required fix (either is sufficient):
1. Commit a capture driver script that calls `demo_issue_move`, logs the
   GATE_B lines, and writes gate_b_evidence.json during the run; or
2. Archive the original local runtime log of the evidence run in
   docs/visual_baseline/gate_b_20260920/ and amend EVIDENCE_RECORD.md to point
   at it.

Minor observations (non-blocking):
- gate_b_mid_move_1.png and gate_b_mid_move_2.png show the unit already at the
  arrival state; the continuous traversal was not captured. The before/after
  position + heading change still satisfies the contract item.
- gate_b_evidence.json lacks a trailing newline.

## Gate C review dimensions

- Visual regression: none (0-pixel same-renderer diff).
- Gameplay presence and control validity: present and demonstrated in media;
  log provenance condition above.
- Proxy leakage: none.
- Reads as a real RTS product slice rather than a test scene: yes — no debug
  labels in capture, full high-fidelity scene, real PBR vehicle.

## Recommended routing

Gate B is technically complete. Window 00 (control) may update the contract
STATUS to GATE_B_PASS / GATE_C_IN_PROGRESS once the provenance condition
above is committed. The CI workflow does not need to gate on the driver
script; committing it restores reproducibility of the evidence.
